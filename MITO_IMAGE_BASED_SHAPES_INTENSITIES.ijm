// PARAMETER
unit = "µm";
pixelWidth = 0.0645;
pixelHeight  = 0.0645;
// PARAMETER
saveSettings();

title = getTitle();
last_point_ind = lastIndexOf(title,".");
name_short = substring(title, 0, indexOf(title,"_SEG_"));
number_str = substring(title, last_point_ind - 2, last_point_ind);
dir = getDirectory("image");

// open MITOS _pro_ pic;
name_pro = name_short + "_pro_" + number_str + ".tif";
path = dir + name_pro;
open(path);

run("Properties...", "pixel_width=" + pixelWidth + " pixel_height=" + pixelHeight + " unit=" + unit + " global");
run("Set Measurements...", "area mean min perimeter fit shape redirect=" + name_pro + " decimal=3");

selectWindow(title);
run("Analyze Particles...", "  show=Overlay display clear");

selectWindow("Results");
path = dir + name_short + "-Intensities.csv";
saveAs("text", path);
run("Close");

selectWindow(title);
path = dir + name_short + "-Outlines.tif";
save(path);

run("Tile");

restoreSettings();