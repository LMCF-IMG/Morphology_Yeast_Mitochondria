// PARAMETER
noiseSizeInPixels = 30;
numTresh = 20;
// PARAMETER

title = getTitle();
rename("MITO");

var width = getWidth();
var height = getHeight();
var dir = getDirectory("image");
getPixelSize(unit, pixelWidth, pixelHeight);

last_point_ind = lastIndexOf(title,".");
name_pro = substring(title, 0, last_point_ind);
name_short = substring(title, 0, indexOf(title,"_pro_"));
number_str = substring(title, last_point_ind - 2, last_point_ind);

saveSettings();
run("Conversions...", "scale");
run("Options...", "iterations=1 count=1 black do=Nothing");

run("Duplicate...", "title=MITOS-ENH");

// MITO-ENH enhancement
selectWindow("MITOS-ENH");
run("8-bit");
run("Subtract Background...", "rolling=15");
run("Remove Outliers...", "radius=1 threshold=1 which=Bright");
run("Gray Morphology", "radius=1 type=circle operator=close");
run("Enhance Contrast", "saturated=0.05");
run("Apply LUT");

// saving
path = dir + name_pro + "-MITOS-ENH.tif";
save(path);

// Tubeness computing intensities etc.
run("Tubeness", "sigma=2");
rename("MITOS-TUB");
run("8-bit");

// with more thresholds...
for (thresh = 1; thresh <= numTresh; thresh++) 
	thresh_postprocess(thresh);

run("Close All");

function thresh_postprocess(threshold) { 
	selectWindow("MITOS-TUB");
	run("Duplicate...", "title=MITOS-TUB-COPY");	
	setThreshold(threshold, 255, "raw");
	run("Convert to Mask");
	run("Remove Outliers...", "radius=1 threshold=1 which=Bright");
	run("Close-");
	// removing larger noise particles
	run("Analyze Particles...", "size=" + noiseSizeInPixels + "-Infinity pixel show=Masks");
	run("Grays");
	// saving
	path = dir + name_pro + "-MITOS-SEG-THRESH" + threshold + ".tif";
	save(path);
	rename("MITOS-SEG-CLEANED-THRESH" + threshold);
	close("MITOS-TUB-COPY");
}