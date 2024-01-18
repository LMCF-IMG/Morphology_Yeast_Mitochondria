# Morphology_Yeast_Mitochondria
Analysis of morphology of control and H2O2-treated *mitochondria* in images acquired by a widefield fluorescence microscope (WF) to distinguish differences between a wildtype strain (WT) (both control and H2O2-treated) and a mutant strain the experiments (both control and H2O2-treated as well). The analysis was done with and the pictures were created and provided by Dr. Jana Vojtová, [Laboratory of Cell Reproduction, Institute of Microbiology of the Czech Academy of Sciences, Prague, Czech Republic](https://mbucas.cz/en/research/biology-of-the-cell-and-bioinformatics/laboratory-of-cell-reproduction/))

**Macros for [ImageJ/Fiji](https://fiji.sc/).**

### Short description

Two images are **inputs** to the analysis: 1. fluorescence image of mitochondria - **Fig. 1**; 2. DIC image of corresponding yeast cells of the same field of view - **Fig. 6**. DIC images are used to relate segmented mitochondria and their parameters to individual cells.

A **microscope** used for the acquisition of both modalities: Olympus IX-71 inverted microscope with a 100x PlanApochromat objective (NA 1.4), GFP filter block exc. 488 nm/em. 507 nm; Nomarski Differential Interference Contrast (DIC) mode.

We have developed **three macros** for processing the images.

- **The first macro**, "MITO_MULTI_GLOBAL_THRESHOLDING.ijm", preprocesses fluorescence images using [(Subtract background)](https://imagejdocu.list.lu/gui/process/subtract_background), eliminating outliers, applying grayscale and binary morphology to reduce data inhomogeneity, and [Tubeness](https://www.longair.net/edinburgh/imagej/tubeness/) to enhance the visualization quality of filamentous structures (mitochondria). Subsequently, a global thresholding method with a predefined range of thresholds is applied to the image, and a particle analyzer is utilized to eliminate small resulting objects. The best segmented image with an appropriate threshold is then selected by an expert, see **Fig. 2** (thresholds applied: left=4, right=13).
-  As an entry into **the second macro**, "MITO_CELL_BASED_ANALYSIS.ijm", fluorescent images with mitochondria, their segmentation, and corresponding DIC images are utilized. The segmented image undergoes two processes: the application of [Local thickness](https://imagej.net/imagej-wiki-static/Local_Thickness), **Fig. 4**, to determine the thickness of mitochondria and [skeletonization](https://imagej.net/plugins/skeletonize3d), **Fig. 5**, to ascertain the lengths, branching, and determination of [Branching Factor](https://www.tandfonline.com/doi/full/10.3109/01913123.2015.1054013) and Filamentous Factor of the mitochondria. Subsequently, the image of yeast cells from DIC is segmented using the [Cellpose](https://github.com/MouseLand/cellpose) method, **Fig. 7**, individual cell masks are created, and from these, stacks are generated containing segmentation, skeletons, and local thickness of these cells. Using these stacks, measurements are taken for the lengths of all mitochondria in each cell, their average thickness, average intensity, mitochondrial area, circularity, and cell area. All supporting images, i.e., resulting Cellpose segmentation, generated masks, and stacks with local thickness, skeletons, and mitochondrial segmentation, created as TIF files, and numerical results, i.e., the skeleton analysis result for calculating the Branching and Filamentous Factor and the morphological analysis result of all cells, created as CSV files, are finally saved to disk for verification.
-  **The third, straightforward macro**, "MITO_IMAGE_BASED_SHAPES_INTENSITIES.ijm", operates by opening a segmented image in Fiji (containing the "SEG" string according to the convention specified below). The corresponding fluorescence image (with the "pro" string) must be in the same directory. The macro also opens it and performs an analysis of the intensities of individual mitochondria and their morphological characteristics. The results, saved to the disk in the same directory, include an image with numbered outlines of mitochondria and a CSV file containing their parameters. In the image, the mitochondria's numbers correspond to their indices in the table, listing area, average, minimum and maximum intensity, perimeter, length of the major and minor axes of the circumscribed ellipse, their angle, and [morphological characteristics](https://imagej.net/ij/docs/menus/analyze.html#set) – circularity, aspect ratio, roundness, solidity. In this case, however, the analysis is conducted collectively on the entire image and is not referenced to individual yeast cells.

For comparison, we **segmented mitochondria using two different methods, Fig. 2-3**. The first method involved global thresholding, "MITO_MULTI_GLOBAL_THRESHOLDING.ijm", as shown in Fig. 2, while the second method utilized [MitoSegNet](https://github.com/mitosegnet), Fig. 3. The aim was to demonstrate the advantages of deep learning for more precise mitochondrial segmentation. However, the original model of the MitoSegNet project did not entirely succeed with our images. Therefore, we annotated our images and retrained the model, see the link below.

A triplet of images (mitochondria, their segmentation by MitoSegNet and DIC) for testing purposes is attached to this webpage. It is thus possible to practically try out both the attached macros for global thresholding and subsequent mitochondrial analysis, respectively. In case you wish to experiment with thresholding mitochondria using [MitoSegNet](https://github.com/mitosegnet), which offers a comprehensive application for mitochondrial segmentation, the retrained model is also available:

[Link to the retrained MitoSegNet model](https://owncloud.cesnet.cz/index.php/s/cnDFxKV5wVLLTt5), cca 355MB.

### Comments to macros attached

General naming convention of our images:
- Experiment Name_DIC_number.tif = DIC image;
- Experiment Name_pro_number.tif = fluorescence image with mitochondria;
- Experiment Name_SEG_number.tif = segmented mitochondria image; 

#### MITO_MULTI_GLOBAL_THRESHOLDING.ijm

Two **parameters** here are applied here, firstly, "*noiseSizeInPixels*", i.e. after global thresholding objects having sizes smaller and equal to this number are removed from the picture. Secondly, "*numThresh*" is number of consecutive global thresholds applied to the fluorescence image.

**Using**: Open image file "alpha_WT_control_pro_02.tif" in Fiji, then open macro file "MITO_MULTI_GLOBAL_THRESHOLDING.ijm", press Run and "numThresh" images will be created in the directory where "alpha_WT_control_pro_02.tif" is placed. Preprocessed version of the input image is also stored with the suffix "-MITOS-ENH.tif". The chosen binary image renamed according to the above mentioned convention can enter the following analysis.

#### MITO_CELL_BASED_ANALYSIS.ijm

##### Prerequisities:

- [Anaconda](https://www.anaconda.com/) installed
- [Cellpose](https://github.com/MouseLand/cellpose) environment created and installed
- [Cellpose wrapper](https://github.com/BIOP/ijl-utilities-wrappers) for Fiji installed

**Parameters** are here *strings* defining the above mentioned naming convention and *image calibration*.

**Using**: Open macro file "MITO_CELL_BASED_ANALYSIS.ijm", press Run and Open dialog appears. Choose "alpha_WT_control_DIC_02.tif" file, press OK. Macro opens other files, i.e. "alpha_WT_control_pro_02.tif" and "alpha_WT_control_SEG_02.tif" and runs the morfological analysis of mitochondria individually for all yeast cells. All results are then stored in the directory where "alpha_WT_control_DIC_02.tif" is placed. Open resulting CSV files by Excel and use comma as a separator. Since the macro computes morfological parameters for each cell separately, it takes several minutes to finish. 

#### MITO_IMAGE_BASED_SHAPES_INTENSITIES.ijm

**Parameters** are *image calibration* values.

**Using**: Open a segmented picture, "alpha_WT_control_SEG_02.tif", then macro file "MITO_IMAGE_BASED_SHAPES_INTENSITIES.ijm" and press Run. All results are then stored in the directory where the segmented picture is placed. Open resulting CSV files by Excel and use comma as a separator.

### Computation of Branching and Filamentous Factors from numerical results from "MITO_CELL_BASED_ANALYSIS.ijm"

**Branching Factor** = the SUM of all branch points per skeleton / the SUM of all end points per skeleton.

It is evaluated for the whole image of segmented mitochondria using resulting "*-Branching-Factor.CSV" file. Apply summing all values in the column C-Junctions (=branch points), the same in the column D-End-point voxels (=end points) and compute the value. The higher the Branching Factor, the higher richness and mutual interconnections of mitochondria; the lower the Branching Factor, the shorter and more separated mitochondria in the image.

**Filamentous Factor** = (the SUM of all branch points per skeleton + the SUM of branches per skeleton) / the SUM of all end points per skeleton.

Apply summing all values in the column B-Branches, the same for C-Junctions (=branch points) and for D-End-point voxels (=end points) and compute the value. The higher the Filamentous Factor, the more connected filaments the mitochondria network has got.

#### Comments to dead cells

In DIC images, occasional occurrences of dead cells are also observed, which could potentially adversely affect the analysis. These cells are identifiable as darker objects, as seen in Fig. 6. In fluorescence images, corresponding objects exhibit shapes resembling the original cells but with lower intensity and without recognized mitochondria. Segmentation based on deep learning do not detect these shapes, as it is not trained for them. Similarly, segmentation based on global thresholding avoids them, given that the average intensities of these cells fall below the chosen threshold. Consequently, images of dead cells are thus excluded from the analysis.

Fig. 1: **Fluorescence images** of mitochondria (WILD Control/WILD Treated):
![Fluo-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/0dbbf106-dc14-40f9-930c-456b582716d5)

Fig. 2: Fluorescence images of mitochondria **segmented** by global thresholding, using "MITO_MULTI_GLOBAL_THRESHOLDING.ijm", (thresholds applied: left=4, right=13):
![GlobThresh-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/b8bbfd60-1801-4afb-8544-99fadbb0f552)

Fig. 3: Fluorescence images of mitochondria **segmented** by the retrained model of [MitoSegNet](https://www.cell.com/iscience/fulltext/S2589-0042(20)30793-8):
![MitoSegNet-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/1d5e7f21-1311-4fee-9c70-5adfa75cf7e8)

Fig. 4: [Local thickness](https://imagej.net/imagej-wiki-static/Local_Thickness) images created from data segmented by MitoSegNet, see Fig. 3 :
![LocalThickness-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/854982f6-bd8c-42d1-a7ea-b46b9734b035)

Fig. 5: [Skeletons](https://imagej.net/plugins/skeletonize3d) created from data segmented by MitoSegNet, see Fig. 3:
![Skeleton-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/e3204a1e-dd76-4f1e-8003-b63d48388288)

Fig. 6: **DIC** images of yeast cells:
![DIC-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/c1503bd4-4bee-4a52-8c4d-9b3188400a00)

Fig. 7: DIC images of yeast cells **segmented** by [Cellpose](https://github.com/MouseLand/cellpose):
![Cellpose-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/c8bccab0-f102-4702-9492-e65a092c75c3)
