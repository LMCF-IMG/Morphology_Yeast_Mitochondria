// Batch fragment-based mitochondrial analysis (single-plane TIFF images).
// Matching markers: exactly _pro_ and _SEG_ (case-sensitive).
// Example: sample_pro_01.tif <-> sample_SEG_01.tif
// All filename parts outside the marker must match exactly.

// PARAMETERS
unit = "micron";
pixelWidth = 0.0645;
pixelHeight = 0.0645;

// Pixel calibration for all image pairs in the selected folder.
Dialog.create("Fragment-based analysis settings");
Dialog.addNumber("Pixel width:", pixelWidth, 6, 12, "µm");
Dialog.addNumber("Pixel height:", pixelHeight, 6, 12, "µm");
Dialog.show();
pixelWidth = Dialog.getNumber();
pixelHeight = Dialog.getNumber();
if (isNaN(pixelWidth) || isNaN(pixelHeight) || pixelWidth <= 0 || pixelHeight <= 0)
    exit("Pixel width and height must be positive numbers.");

inputDir = getDirectory("Select the folder containing image pairs");
files = getFileList(inputDir);
Array.sort(files);
outputDir = inputDir + "Fragment_Analysis" + File.separator;
version = 2;
while (File.exists(outputDir)) {
    outputDir = inputDir + "Fragment_Analysis_" + version + File.separator;
    version++;
}
File.makeDirectory(outputDir);

saveSettings();
setBatchMode(true);
processed = 0;
skipped = 0;
candidates = 0;
logText = "MITO fragment-based analysis\nInput folder: " + inputDir + "\n";

for (i = 0; i < files.length; i++) {
    rawName = files[i];
    if (!isTiff(rawName)) continue;
    rawStem = stem(rawName);
    rawKey = pairKey(rawStem, "raw");
    if (rawKey == "") continue;
    candidates++;
    showStatus("Analyzing image pairs: " + candidates);
    showProgress(i, files.length);

    matchesFound = 0;
    rawMatches = 0;
    segName = "";
    for (j = 0; j < files.length; j++) {
        if (!isTiff(files[j])) continue;
        candidateStem = stem(files[j]);
        candidateRawKey = pairKey(candidateStem, "raw");
        candidateSegKey = pairKey(candidateStem, "seg");
        if (candidateRawKey == rawKey) rawMatches++;
        if (candidateSegKey == rawKey) {
            matchesFound++;
            segName = files[j];
        }
    }
    if (matchesFound != 1 || rawMatches != 1) {
        skipped++;
        logText += "SKIPPED: " + rawName + " (matching source images: " + rawMatches + ", segmentation images: " + matchesFound + ")\n";
        continue;
    }

    open(inputDir + rawName);
    rawID = getImageID();
    // A unique window title prevents measurement redirection to other open images.
    rename("MITO_source_" + abs(rawID));
    rawTitle = getTitle();
    getDimensions(rw, rh, rc, rz, rt);
    open(inputDir + segName);
    segID = getImageID();
    getDimensions(sw, sh, sc, sz, st);
    valid = rw == sw && rh == sh && rc == 1 && rz == 1 && rt == 1 && sc == 1 && sz == 1 && st == 1;
    if (!valid || !is("binary")) {
        skipped++;
        logText += "SKIPPED: " + rawName + " / " + segName + " (requires matching single-plane grayscale images and a binary segmentation mask)\n";
        selectImage(segID); close();
        selectImage(rawID); close();
        continue;
    }

    selectImage(rawID);
    run("Properties...", "pixel_width=" + pixelWidth + " pixel_height=" + pixelHeight + " unit=" + unit);
    selectImage(segID);
    run("Properties...", "pixel_width=" + pixelWidth + " pixel_height=" + pixelHeight + " unit=" + unit);
    run("Set Measurements...", "area mean min perimeter fit shape redirect=[" + rawTitle + "] decimal=3");
    // MitoSegNet masks: white foreground (255), black background (0).
    setThreshold(255, 255);
    run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Overlay display clear");
    outputStem = stem(segName);
    if (nResults > 0)
        saveAs("Results", outputDir + outputStem + "-Intensities.csv");
    else
        File.saveString("Area,Mean,Min,Max,Perim.,Major,Minor,Angle,Circ.,AR,Round,Solidity\n", outputDir + outputStem + "-Intensities.csv");
    count = nResults;
    selectImage(segID);
    resetThreshold();
    saveAs("Tiff", outputDir + outputStem + "-Outlines.tif");
    close();
    selectImage(rawID); close();
    processed++;
    logText += "PROCESSED: " + rawName + " / " + segName + " (fragments: " + count + ")\n";
}

// Report segmentation images without a source image.
for (i = 0; i < files.length; i++) {
    if (!isTiff(files[i])) continue;
    orphanStem = stem(files[i]);
    segKey = pairKey(orphanStem, "seg");
    if (segKey == "") continue;
    found = 0;
    for (j = 0; j < files.length; j++) {
        if (isTiff(files[j])) {
            sourceStem = stem(files[j]);
            sourceKey = pairKey(sourceStem, "raw");
            if (sourceKey == segKey) found++;
        }
    }
    if (found == 0) {
        skipped++;
        logText += "SKIPPED: " + files[i] + " (no matching source image)\n";
    }
}
restoreSettings();
setBatchMode(false);
showProgress(1);
summary = "Processed pairs: " + processed + "\nSkipped entries: " + skipped + "\n\nOutput folder:\n" + outputDir;
logText += "\n" + summary + "\n";
File.saveString(logText, outputDir + "Analysis_Log.txt");
print(logText);
showStatus("MITO fragment-based analysis completed.");
showMessage("Batch analysis completed", summary + "\n\nSee Analysis_Log.txt for details.");

function isTiff(name) {
    lower = toLowerCase(name);
    return endsWith(lower, ".tif") || endsWith(lower, ".tiff");
}

function stem(name) {
    return substring(name, 0, lastIndexOf(name, "."));
}

function pairKey(name, kind) {
    marker = "_pro_";
    if (kind == "seg") marker = "_SEG_";
    position = indexOf(name, marker);
    if (position < 0) return "";
    suffix = substring(name, position + lengthOf(marker));
    // Reject ambiguous names containing the marker more than once.
    if (indexOf(suffix, marker) >= 0) return "";
    return substring(name, 0, position) + "<PAIR>" + suffix;
}
