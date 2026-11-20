// Batch preprocessing of fluorescence MIPs for segmentation.
// Scan only the selected folder, not its subfolders.
// Original TIFF files are copied unchanged into Originals/.
// Use those originals for quantitative fluorescence measurements.

// PARAMETERS
rollingRadius = 15;
outlierRadius = 1;
outlierThreshold = 1;
originalsFolder = "Originals";

inputDir = getDirectory("Select the folder containing original _pro_ MIP TIFF images");
files = getFileList(inputDir);
Array.sort(files);
originalDir = inputDir + originalsFolder + File.separator;
File.makeDirectory(originalDir);
if (!File.exists(originalDir))
    exit("Could not create the Originals folder. Check write permissions.");

logPath = originalDir + "Preprocessing_Log.txt";
logIndex = 2;
while (File.exists(logPath)) {
    logPath = originalDir + "Preprocessing_Log_" + logIndex + ".txt";
    logIndex++;
}
logText = "MITO batch preprocessing\nInput folder: " + inputDir + "\n";
logText += "Background rolling radius: " + rollingRadius + " pixels\n";
logText += "Bright outliers: radius=" + outlierRadius + ", threshold=" + outlierThreshold + "\n";
logText += "8-bit conversion: per-image min/max scaling (segmentation only)\n\n";
File.saveString(logText, logPath);
processed = 0;
skipped = 0;
ignored = 0;
candidates = 0;
saveSettings();
setBatchMode(true);

for (i = 0; i < files.length; i++) {
    name = files[i];
    sourcePath = inputDir + name;
    lowerName = toLowerCase(name);
    if (File.isDirectory(sourcePath)) continue;
    if (!endsWith(lowerName, ".tif") && !endsWith(lowerName, ".tiff")) {
        ignored++;
        continue;
    }
    baseName = substring(name, 0, lastIndexOf(name, "."));
    if (indexOf(baseName, "_pro_") < 0 || endsWith(toLowerCase(baseName), "_orig")) {
        ignored++;
        continue;
    }
    candidates++;
    showStatus("MITO preprocessing: " + name);
    showProgress(i, files.length);
    originalPath = originalDir + baseName + "_orig.tif";
    legacyPath = inputDir + baseName + "_orig.tif";
    if (File.exists(originalPath) || File.exists(legacyPath)) {
        skipped++;
        logText += "SKIPPED: " + name + " (original backup already exists; possible previous processing)\n";
        File.saveString(logText, logPath);
        continue;
    }

    // Record the active file so an interrupted run can be diagnosed.
    File.saveString(logText + "STARTED: " + name + "\n", logPath);
    open(sourcePath);
    imageID = getImageID();
    getDimensions(w, h, channels, slices, frames);
    if (channels != 1 || slices != 1 || frames != 1 || bitDepth == 24) {
        skipped++;
        logText += "SKIPPED: " + name + " (requires a single-plane grayscale MIP)\n";
        close();
        File.saveString(logText, logPath);
        continue;
    }
    originalDepth = bitDepth;

    // Copy the original disk file before changing or overwriting the source.
    File.copy(sourcePath, originalPath);
    backupOK = File.exists(originalPath);
    if (backupOK) {
        originalBytes = File.length(originalPath);
        sourceBytes = File.length(sourcePath);
        backupOK = (originalBytes == sourceBytes);
    }
    if (!backupOK) {
        skipped++;
        logText += "SKIPPED: " + name + " (original backup could not be verified; source left unchanged)\n";
        close();
        File.saveString(logText, logPath);
        continue;
    }

    selectImage(imageID);
    run("Select None");
    run("Subtract Background...", "rolling=" + rollingRadius);
    run("Remove Outliers...", "radius=" + outlierRadius + " threshold=" + outlierThreshold + " which=Bright");
    setOption("ScaleConversions", true);
    resetMinAndMax();
    getMinAndMax(scaleMin, scaleMax);
    run("8-bit");
    saveAs("Tiff", sourcePath);
    close();
    processed++;
    logText += "PROCESSED: " + name + " | original=" + originalDepth + "-bit | output=8-bit | pre-conversion range=" + scaleMin + " to " + scaleMax + "\n";
    File.saveString(logText, logPath);
}

restoreSettings();
setBatchMode(false);
showProgress(1);
summary = "Matching TIFF files: " + candidates + "\nProcessed: " + processed + "\nSkipped: " + skipped + "\nOther files ignored: " + ignored;
logText += "\nCOMPLETED\n" + summary + "\n\nUse the original MIPs for fluorescence intensity measurements.\n";
File.saveString(logText, logPath);
print(logText);
showStatus("MITO batch preprocessing completed.");
showMessage("Batch preprocessing completed", summary + "\n\nOriginal MIPs:\n" + originalDir + "\n\nProcessed 8-bit images retain their original filenames in:\n" + inputDir + "\n\nLog:\n" + logPath);
