// PARAMETERS
var strDIC = "_DIC_";
var strFLUO = "_pro_";
var strSEG = "_SEG_";

var unit = "µm";
var pixelWidth = 0.0645;
var pixelHeight  = 0.0645;
// PARAMETERS

// settings
var showUpdatePixels = false;
debugging = false;
// settings

// Global variables
var width, height, numSlices;
var titleDIC, titleFLUO;
var name_short, number_str;
var dir;
var index = 0;						// index of a cell in the picture, for counting cells with mito
// Global variables

pathDIC = File.openDialog("Select a DIC File...");
dir = File.getParent(pathDIC);
dir = dir + "\\";

if (endsWith(pathDIC, ".tif") && (indexOf(pathDIC, strDIC) > 0)) {
	// open DIC
	open(pathDIC);
	titleDIC = getTitle();
	// img params
	width = getWidth();
	height = getHeight();
	rename("DIC");
	// strings
	last_point_ind = lastIndexOf(titleDIC,".");
	name_short = substring(titleDIC, 0, indexOf(titleDIC,"_DIC_"));
	number_str = substring(titleDIC, last_point_ind - 2, last_point_ind);		
	// open FLUO
	path = dir + "\\" + name_short + strFLUO + number_str + ".tif";
	open(path);
	titleMITO = getTitle();
	rename("MITOS");
	
	// data preparation for the next analyses and with DIC segmentation by Cellpose
	preparation();
	
	// cleaning from "BAD" mito objects coming from non-ideal segmentation
	delBadObjectsInSEGStack();
	
	run("Synchronize Windows");
	
	if (debugging) {
		run("Tile");
		waitForUser("Press OK to continue...");
	}
	
	// since SEGS were cleaned to SEGS-CLEANED
	close("SEGS");
	run("Tile");

	// mito analysis
	evaluation();
	
	if (debugging)
		waitForUser("Press OK to continue...");
	
	run("Close All");
}
else
	showMessage("Error", "No DIC file in TIF format selected! Macro ends...");

////////////////////////////////////////////////////////////////////////////////////////////////////
function delBadObjectsInSEGStack() {
	// cleaning the SEG-STCK from false mitos that came from neighbouring cells
	// due to the masks from cellpose applied to DIC
	// OUTPUT: the cleaned Stack - stckSegCleaned
	stckSeg = "SEGS";
	stckSkel = "SKELS";		
	stckSegCleaned = "SEGS-CLEANED";
	
	setBatchMode(true);
	
	selectWindow(stckSeg);
	getDimensions(width, height, channels, numSlices, frames);
	print("Number of slices in the stack: " + numSlices);
	
	newImage(stckSegCleaned, "8-bit black", width, height, 1);
	
	for (i = 1; i <= numSlices; i++) {
		showStatus("Erasing wrong mito parts: Processing ... " + i-1 + "th cell of " + numSlices-1 + ".");
		selectWindow(stckSeg);
		setSlice(i);
		run("Duplicate...", "title=SEG");
		
		selectWindow(stckSkel);
		setSlice(i);
		run("Duplicate...", "title=SKEL");
		
		delBadObjectsInImg("SEG", "SKEL", i);
		
		run("Concatenate...", "  title=" + stckSegCleaned + " image1=" + stckSegCleaned + " image2=SEG");	
		close("SEG");
		close("SKEL");
	}
	
	selectWindow(stckSegCleaned);
	setSlice(1);
	run("Delete Slice");
	
	// saving + renamimg
	selectWindow(stckSegCleaned);
	path = dir + name_short + strSEG + number_str + "-SEG-STCK-CLEANED.tif";
	save(path);
	rename("SEGS-CLEANED");
	
	// Log for debugging
	selectWindow("Log");
	path = dir + name_short + strSEG + number_str + "-ERASING.txt";
	saveAs("text", path);
	run("Close");	
	
	setBatchMode(false);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
function delBadObjectsInImg(imgSeg, imgSkel, imNumber) {
	selectWindow(imgSeg);
	
	setForegroundColor(0, 0, 0);
	run("Set Measurements...", "area redirect=None decimal=3");	
	
	run("Analyze Particles...", "size=1-Infinity add");
	numSeg = roiManager("count");
	
	selectWindow(imgSkel);
	run("Analyze Particles...", "size=1-Infinity add");
	numSkel = roiManager("count") - numSeg;
	
	// Overlapping ROIs select
	overlappingROIsInSeg = newArray();
	toBeDeletedROIsInSeg = newArray();
	
	for (i = 0; i < numSeg; i++) { 
		tobepreserved = false;
		for (j = numSeg; j < numSeg+numSkel; j++) {
			roiManager("Select", newArray(i,j));
			roiManager("AND");
			
			if (selectionType()>-1) {
				tobepreserved = true;
				overlappingROIsInSeg = Array.concat(overlappingROIsInSeg,i);
			}
		}
		if (tobepreserved == false) {
			toBeDeletedROIsInSeg = Array.concat(toBeDeletedROIsInSeg,i);
			print(imNumber + ". pic: " + i + "., " + j + ". objects do NOT intersect");
		}
	}
	
	roiManager("Select", toBeDeletedROIsInSeg);
	
	// deleting bad objects/rois
	if (toBeDeletedROIsInSeg.length > 0) {
		selectWindow(imgSeg);
		for (i = 0; i < toBeDeletedROIsInSeg.length; i++) {
			roiManager("select", toBeDeletedROIsInSeg[i]);
			roiManager("fill");
			print(imNumber + ". pic: object was erased");			
		}
	}
	
	// cleaning the roi manager
	roiManager("reset")
	
	selectWindow(imgSkel);
	roiManager("Show All");
	roiManager("Show None");
	selectWindow(imgSeg);
	roiManager("Show All");
	roiManager("Show None");	
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function evaluation() {
	saveSettings();
	run("Conversions...", "scale");
	run("Options...", "iterations=1 count=1 black do=Nothing");
	run("Set Measurements...", "area shape redirect=None decimal=3");
	run("Properties...", "pixel_width=" + pixelWidth + " pixel_height=" + pixelHeight + " global");
	
	setBatchMode(true);
	outputString = "Index;Cell No.;Skeleton_No;Length ["+unit+"];Average Thickness ["+unit+"];Average Intensity;" + 
					"Mito Area["+unit+"2];Cell Area["+unit+"2];Relative Area-Mito/Cell[-];Circ.;# Skeletons;# Fragments; EQUAL?";
	print(outputString);

	// extraction of images from stacks and mito eval
	for (i = 2; i <= numSlices; i++) {
	//for (i = 2; i < 10 ; i++) {
		showStatus("Evaluation: Processing ... " + i-1 + "th cell of " + numSlices-1 + ".");
		selectWindow("MITOS");
		run("Duplicate...", "title=MITOS-COPY");
		selectWindow("SKELS");
		Stack.setSlice(i);
		run("Duplicate...", "title=SKELS-COPY");
		selectWindow("THCKS");
		Stack.setSlice(i);
		run("Duplicate...", "title=THCKS-COPY");
		selectWindow("MASKS");
		Stack.setSlice(i);
		run("Duplicate...", "title=MASKS-COPY");	
		selectWindow("SEGS-CLEANED");
		Stack.setSlice(i);
		run("Duplicate...", "title=SEGS-CLEANED-COPY");		
		
		// index reflects here the order of cells in stacks including first empty slice
		mitoEval("MITOS-COPY", "SKELS-COPY", "THCKS-COPY", "MASKS-COPY", "SEGS-CLEANED-COPY", i); 
	}
	setBatchMode(false);
	
	selectWindow("Log");
	path = dir + name_short + strSEG + number_str + "-Results.csv";
	saveAs("text", path);
	run("Close");	
	
	restoreSettings();	
}

//////////////////////////////////////////////////////////////////////////////
function mitoEval(mitoOrigWin, mitoSkeletWin, mitoLocThckWin, mitoMaskWin, mitoSegWin, numCell) { 
	
	// getting image calibration
	selectWindow(mitoOrigWin);
	
	// create labeled skeleton
	selectWindow(mitoSkeletWin);
	run("Analyze Skeleton (2D/3D)", "prune=[shortest branch] display");
	selectWindow("Results");
	run("Close");
	close("Tagged skeleton");
	close("Skeleton");
	selectWindow(mitoSkeletWin + "-labeled-skeletons");
	rename("Labeled_Skeletons");
	
	skeletons = newArray(width * height);
	for (i = 0; i < width * height; i++)
		skeletons[i] = 0;
	
	int = 0;
	skeletPresent = false;
	// histogram of skeleton labels creation
	selectWindow("Labeled_Skeletons");
	for (y = 0; y < height; y++)
		for (x = 0; x < width; x++) {
			int = getPixel(x, y);
			if (int > 0) {
				skeletons[int] = skeletons[int] + 1;
				skeletPresent = true;
			}
		}
		
	if (skeletPresent) {
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// evaluation of average thicknesses and intensities of actins with using individual color-labeled parts of the skeleton
		
		// array with coordinates of a single skeleton part - (x, y) per 1 pixel in one array
		oneSkeleton = newArray(width * height * 2);
		for (i = 0; i < width * height * 2; i++)
			oneSkeleton[i] = 0;
		
		index++;  // index of a cell in the picture, for counting cells with mito
		
		sktInt = 0;
		frequency = 0;
		sktLength = 0;
		xx = 0;
		yy = 0;
		thicknessAccum = 0;
		skeletonIndex = 0;
		intensityAccum = 0;
		
		for (i = 0; i < width * height; i++)
		{
			frequency = skeletons[i];
			if (frequency > 0)
			{
				skeletonIndex++;
				sktInt = i;
				// scannig the skeleton image and find all the pixels of one skeleton part of the same color label
				selectWindow("Labeled_Skeletons");
				sktLength = 0;
				for (y = 0; y < height; y++)
					for (x = 0; x < width; x++) {
						int = getPixel(x, y);
						if (int == sktInt)
						{
							oneSkeleton[2 * sktLength] = x;
							oneSkeleton[2 * sktLength + 1] = y;
							sktLength++;
							setPixel(x, y, 10000);
						}
					}
				//if (!processWholeFolder)
				if (showUpdatePixels)
					updateDisplay();					
		
				// average thickness of the now analyzed skeleton part
				selectWindow(mitoLocThckWin);
				thicknessAccum = 0;
				for (l = 0; l < sktLength; l++)
				{
					xx = oneSkeleton[2 * l];
					yy = oneSkeleton[2 * l + 1];
					thicknessAccum = thicknessAccum + getPixel(xx, yy);
					setPixel(xx, yy, 10000);
				}
				//if (!processWholeFolder)
				if (showUpdatePixels)
					updateDisplay();					
		
				// average intensity
				selectWindow(mitoOrigWin);
				intensityAccum = 0;
				for (l = 0; l < sktLength; l++)
				{
					xx = oneSkeleton[2 * l];
					yy = oneSkeleton[2 * l + 1];
					intensityAccum = intensityAccum + getPixel(xx, yy);
					setPixel(xx, yy, 65535);
				}
				//if (!processWholeFolder)
				if (showUpdatePixels)
					updateDisplay();					
		
				thicknessAvg = thicknessAccum / sktLength;
				intensityAvg = intensityAccum / sktLength;				
				
				// for each skeleton part writing to Fiji Log file: number, color, length, average thickness, average intensity 
				outputString = "" + index + ";" + numCell + ";" + skeletonIndex + ";" + sktLength*pixelWidth + ";" +
							thicknessAvg*pixelWidth + ";" + intensityAvg;
				print(outputString);
			}
		}
		// cell, mito areas
		selectWindow(mitoMaskWin);
		setAutoThreshold("Default dark");
		run("Create Selection");
		getStatistics(area);
		areaCell = area;
						
		selectWindow(mitoSegWin);
		setAutoThreshold("Default dark");
		run("Create Selection");
		getStatistics(area);
		areaMito = area;
		
		outputString = "" + index + ";;;;;;" + areaMito + ";" + areaCell + ";" + areaMito/areaCell  + ";;" + skeletonIndex;
		print(outputString);
			
		// analysis of mito shapes using circularity
		selectWindow(mitoSegWin);
		run("Analyze Particles...", "size=1-Infinity pixel display");
		for (i = 0; i < nResults; i++) {
			outputString = ";;;;;;;;;";					
			circ = getResult("Circ.", i);
			print(outputString + circ);
		}
		outputString = ";;;;;;;;;;;";
		if (skeletonIndex == nResults)
			print(outputString + nResults + "; OK");
		else if ((skeletonIndex < nResults))
			print(outputString + nResults + "; MORE MITOS");
		else
			print(outputString + nResults + "; MORE SKELS");
		print("");
	}
	
	// closing
	close(mitoOrigWin);
	close(mitoSkeletWin);
	close(mitoLocThckWin);
	close(mitoMaskWin);
	close(mitoSegWin);
	close("Labeled_Skeletons");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
function preparation() {
	saveSettings();
	run("Conversions...", "scale");
	run("Options...", "iterations=1 count=1 black do=Nothing");
	
	// open SEG pic
	path = dir + name_short + strSEG + number_str + ".tif";
	open(path);
	rename("MITOS-SEG");
	
	// Local Thickness applied to the binary image
	run("Local Thickness (complete process)", "threshold=20");
	rename("MITOS-LOC_THICK");
	
	// Skeletonization of MITOS-SEG
	selectWindow("MITOS-SEG");
	run("Remove Outliers...", "radius=1 threshold=50 which=Bright");
	run("Duplicate...", "title=MITOS-SKELET");
	run("Skeletonize (2D/3D)");
	rename("MITOS-SKELET");
	
	// Data for Branching Factor per the whole image
	selectWindow("MITOS-SKELET");
	run("Analyze Skeleton (2D/3D)", "prune=[shortest branch] display");
	selectWindow("Results");
	path = dir + name_short + strSEG + number_str + "-Branching-Factor.csv";
	saveAs("text", path);
	run("Close");
	close("Tagged skeleton");
	close("Skeleton");
	close("MITOS-SKELET-labeled-skeletons");
	
	// saving important images
	selectWindow("MITOS-SKELET");
	path = dir + name_short + strSEG + number_str + "-MITOS-SKELET.tif";
	save(path);
	rename("MITOS-SKELET");
	selectWindow("MITOS-LOC_THICK");
	path = dir + name_short + strSEG + number_str + "-MITOS-LOC_THICK.tif";
	save(path);
	rename("MITOS-LOC_THICK");
	
	// segmentation of DIC
	selectWindow("DIC");
	run("Cellpose Advanced", "diameter=69 cellproba_threshold=0.0 flow_threshold=0.4 "  + 
		"anisotropy=1.0 diam_threshold=12.0 model=cyto nuclei_channel=2 cyto_channel=1 " + 
		"dimensionmode=2D stitch_threshold=-1.0 omni=false cluster=false additional_flags=");
	run("3-3-2 RGB");
	
	path = dir + name_short + strDIC + number_str + "_cellpose.tif";
	save(path);
	rename("DIC-cellpose");

	// creating masks from cellpose data and adding them to a stack
	selectWindow("DIC-cellpose");
	getStatistics(area, mean, min, max, std, histogram);
	setOption("BlackBackground", true);
	call("ij.plugin.frame.ThresholdAdjuster.setMode", "B&W");

	newImage("MASKS", "8-bit black", width, height, 1);
	newImage("MITOS-SKEL-STCK", "8-bit black", width, height, 1);
	newImage("MITOS-THCK-STCK", "32-bit black", width, height, 1);
	newImage("MITOS-SEG-STCK", "8-bit black", width, height, 1);

	// iterate for all found cells in cellpose image to create masks
	// segmenting cells with mito in MITO image
	// setBatchMode(true); - does not work well with this!
	for (i = 1; i <= max; i++) {
		showStatus("Preparation: Processing ... " + i-1 + "th cell of " + numSlices-1 + ".");
		// one cell mask creation
		selectWindow("DIC-cellpose");
		run("Duplicate...", "title=MASK");
		setThreshold(i, i, "raw");
		run("Convert to Mask");
		run("Duplicate...", "title=MASK-COPY");
		run("Divide...", "value=255");
		
		// one cell skeleton image
		imageCalculator("Multiply create", "MITOS-SKELET","MASK-COPY");
		selectWindow("Result of MITOS-SKELET");
		rename("MITOSKELET");
		
		// one cell thickness image
		imageCalculator("Multiply create", "MITOS-LOC_THICK","MASK-COPY");
		selectWindow("Result of MITOS-LOC_THICK");
		rename("MITOSLOCTHCK");
		
		// one segmented mito image
		imageCalculator("Multiply create", "MITOS-SEG","MASK-COPY");
		selectWindow("Result of MITOS-SEG");
		rename("MITOSSEG");	
	
		// adding to stacks
		run("Concatenate...", "  title=MASKS image1=MASKS image2=MASK");
		run("Concatenate...", "  title=MITOS-SKEL-STCK image1=MITOS-SKEL-STCK image2=MITOSKELET");
		run("Concatenate...", "  title=MITOS-THCK-STCK image1=MITOS-THCK-STCK image2=MITOSLOCTHCK");
		run("Concatenate...", "  title=MITOS-SEG-STCK image1=MITOS-SEG-STCK image2=MITOSSEG");	
		close("MASK-COPY");
	}
	// setBatchMode(false);- does not work well with this!
	
	// saving stacks + stacks renaming for the next processing - evaluation
	selectWindow("MASKS");
	path = dir + name_short + strDIC + number_str + "-MASKS-STCK.tif";
	save(path);
	rename("MASKS");
	
	selectWindow("MITOS-SKEL-STCK");
	path = dir + name_short + strSEG + number_str + "-SKEL-STCK.tif";
	save(path);
	rename("SKELS");
	
	selectWindow("MITOS-THCK-STCK");
	path = dir + name_short + strSEG + number_str + "-THCK-STCK.tif";
	save(path);
	rename("THCKS");	
	
	selectWindow("MITOS-SEG-STCK");
	path = dir + name_short + strSEG + number_str + "-SEG-STCK.tif";
	save(path);
	rename("SEGS");		
		
	restoreSettings();
}