# Morphology_Yeast_Mitochondria

Analysis of Mitochondrial Morphology Using Widefield Fluorescence Microscopy and Image Processing Macros

**Macros for [ImageJ/Fiji](https://fiji.sc/).**

### Introduction

This study entails a meticulous examination of the morphology of control and H2O2-treated mitochondria, employing images acquired through a widefield fluorescence microscope (WF). The primary objective is to discern disparities between a wildtype strain (WT) under both control and H2O2-treated conditions and a mutant strain subjected to the same experimental variations. Dr. Jana Vojtová from the [Laboratory of Cell Reproduction, Institute of Microbiology of the Czech Academy of Sciences, Prague, Czech Republic](https://mbucas.cz/en/research/biology-of-the-cell-and-bioinformatics/laboratory-of-cell-reproduction/)) cooperated with the analysis and provided the images.

### Instrumentation and Imaging Modalities

The Olympus IX-71 inverted microscope equipped with a 100x PlanApochromat objective (NA 1.4) was utilized for imaging both fluorescence and Nomarski Differential Interference Contrast (DIC) modalities. The GFP filter block was employed for fluorescence imaging (exc. 488 nm/em. 507 nm).

### Image Processing Macros

Three distinct macros were developed for ImageJ/Fiji to process the acquired images:

1. **MITO_MULTI_GLOBAL_THRESHOLDING.ijm:**

    - This macro preprocesses fluorescence images (**Fig. 1**) using [background subtraction](https://imagejdocu.list.lu/gui/process/subtract_background), outlier elimination, grayscale and binary morphology, and [Tubeness](https://www.longair.net/edinburgh/imagej/tubeness/) for enhanced visualization of mitochondrial filamentous structures.
    - A global thresholding method with predefined thresholds is applied, followed by the elimination of small objects using a particle analyzer.
    - The optimal segmented image is chosen by an expert based on appropriate thresholds (**Fig. 2**).
    - Usage: Two **parameters** are applied, firstly, "*noiseSizeInPixels*", i.e. after global thresholding objects having sizes smaller and equal to this number are removed from the picture. Secondly, "*numThresh*" is number of consecutive global thresholds applied to the fluorescence image. Open "alpha_WT_control_pro_02.tif" in Fiji, then run the macro. Resulting images and a preprocessed version will be saved in the same directory.


2. **MITO_CELL_BASED_ANALYSIS.ijm:**

    - This macro utilizes fluorescent images, mitochondrial segmentation, and corresponding DIC images (**Fig. 6**). DIC images are used to relate segmented mitochondria and their parameters to individual cells.
    - Processes the segmented image with [local thickness](https://imagej.net/imagej-wiki-static/Local_Thickness) (**Fig. 4**) analysis and [skeletonization](https://imagej.net/plugins/skeletonize3d) (**Fig. 5**) to determine mitochondrial thickness, lengths, branching, [Branching Factor](https://www.tandfonline.com/doi/full/10.3109/01913123.2015.1054013), and Filamentous Factor, see below.
    - Segments yeast cells using the [Cellpose](https://github.com/MouseLand/cellpose) (**Fig. 7**) method and generates stacks containing segmentation, skeletons, and local thickness for each cell.
    - Various measurements are taken for individual mitochondria in each cell, including length, average thickness, intensity, mitochondrial area, circularity, and cell area.
    - Supporting images and numerical results are saved as TIF and CSV files, respectively, for verification.
    - Usage: Requires [Anaconda](https://www.anaconda.com/) installation, [Cellpose](https://github.com/MouseLand/cellpose) environment creation, and [Cellpose wrapper](https://github.com/BIOP/ijl-utilities-wrappers) for Fiji installation. **Parameters** are here *strings* defining the below mentioned naming convention and *image calibration*. Open the macro, select "alpha_WT_control_DIC_02.tif," and run the analysis. Results are stored in the directory of the selected DIC image. When opening resulting CSV files by Excel, use comma as a separator. Since the macro computes morfological parameters for each cell separately, it takes several minutes to finish. 
    
3.	**MITO_IMAGE_BASED_SHAPES_INTENSITIES.ijm:**

    - This macro operates by opening a segmented image in Fiji containing the "SEG" string and its corresponding fluorescence image with the "pro" string in the same directory.
    - It conducts an analysis of intensities, perimeter, length of the major and minor axes of the circumscribed ellipse, and [morphological characteristics](https://imagej.net/ij/docs/menus/analyze.html#set) – circularity, aspect ratio, roundness, solidity – of individual mitochondria on the entire image.
    - Results, including an image with numbered outlines of mitochondria and a CSV file containing their parameters, are saved in the same directory.
    - Usage: **Parameters** are *image calibration* values. Open a segmented picture ("alpha_WT_control_SEG_02.tif"), then run the macro. Results are saved in the directory of the segmented picture.

Naming convention of our images:
- Experiment Name_DIC_number.tif = DIC image;
- Experiment Name_pro_number.tif = fluorescence image with mitochondria;
- Experiment Name_SEG_number.tif = segmented mitochondria image; 

### Comparison of Segmentation Methods:

Mitochondrial segmentation was conducted using two different methods: global thresholding (**Fig. 2**) and [MitoSegNet](https://github.com/mitosegnet) (**Fig. 3**). The purpose was to showcase the advantages of deep learning for precise mitochondrial segmentation. However, the original MitoSegNet model did not entirely succeed with the provided images, prompting the annotation and retraining of the model.

For practical experimentation, a triplet of images (mitochondria, MitoSegNet segmentation, and DIC) is attached to the webpage. Both macros for global thresholding and subsequent mitochondrial analysis are available for testing. Additionally, the retrained MitoSegNet model is provided:

[Link to the retrained MitoSegNet model](https://owncloud.cesnet.cz/index.php/s/cnDFxKV5wVLLTt5), cca 355MB.

### Computation of Branching and Filamentous Factors

**Branching Factor** = the SUM of all branch points per skeleton / the SUM of all end points per skeleton.

It is evaluated for the whole image of segmented mitochondria using resulting "*-Branching-Factor.CSV" file. Apply summing all values in the column C-Junctions (=branch points), the same in the column D-End-point voxels (=end points) and compute the value. The higher the Branching Factor, the higher richness and mutual interconnections of mitochondria; the lower the Branching Factor, the shorter and more separated mitochondria in the image.

**Filamentous Factor** = (the SUM of all branch points per skeleton + the SUM of branches per skeleton) / the SUM of all end points per skeleton.

Apply summing all values in the column B-Branches, the same for C-Junctions (=branch points) and for D-End-point voxels (=end points) and compute the value. The higher the Filamentous Factor, the more connected filaments the mitochondria network has got.

### Comments on Dead Cells

In DIC images, occasional dead cells are observed, potentially impacting the analysis. These cells appear as darker objects (**Fig. 6**). In fluorescence images, similar objects mimic the original cells but with reduced intensity and lacking recognized mitochondria. Deep learning-based segmentation and global thresholding both fail to detect these shapes due to lack of training or intensity below the threshold. As a result, images containing dead cells are excluded from the analysis.

### Images

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
