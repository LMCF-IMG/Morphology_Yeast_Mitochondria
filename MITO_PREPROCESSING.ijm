title = getTitle();
dir = getDirectory("image");

// MITO-ENH enhancement
run("Subtract Background...", "rolling=15");
run("Remove Outliers...", "radius=1 threshold=1 which=Bright");

// saving
path = dir + title;
save(path);
