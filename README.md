# Morphology_Yeast_Mitochondria

Analysis of Mitochondrial Morphology Using Widefield Fluorescence Microscopy and Image Processing Macros

**Macros for [ImageJ/Fiji](https://fiji.sc/).**

**Related publication:**

Vojtová, J., Čapek, M., Willeit, S., Groušl, T., Chvalová, V., Kutejová, E., Pevala, V., Valášek, L.S., & Rinnerthaler, M. (2024). A fully automated morphological analysis of yeast mitochondria from wide-field fluorescence images. *Scientific Reports*, *14*(1), 30144. [https://doi.org/10.1038/s41598-024-81241-0](https://doi.org/10.1038/s41598-024-81241-0)

**Detailed protocol on protocols.io:**

[Quantitative morphological analysis of yeast Saccharomyces cerevisiae mitochondria, and other filamentous structures from wide-field fluorescence images](https://www.protocols.io/view/quantitative-morphological-analysis-of-yeast-sacch-j6r4crd8x)

### Introduction

The examination of the morphology of tubular (control) and spherical (hydrogen peroxide treated) mitochondria in the yeast *Saccharomyces cerevisiae*, utilizing wide-field fluorescence images. Mitochondria were labeled with mitochondria-targeted green fluorescent protein (mtGFP). For segmentation, either the MITO_MULTI_GLOBAL_THRESHOLDING.ijm macro or a retrained deep learning model, MitoSegNet, specifically adapted for yeast cells, can be employed. Subsequent analyses of mitochondria morphology can be conducted using two macros: MITO_CELL_BASED_ANALYSIS.ijm and MITO_FRAGMENT_BASED_ANALYSIS.ijm. Dr. Jana Vojtová from the [Laboratory of Regulation of Gene Expression, Institute of Microbiology of the Czech Academy of Sciences, Prague, Czech Republic](https://www.biomed.cas.cz/mbu/lrge/#top) cooperated with the analyses and provided the images.

### Instrumentation and Imaging Modalities

The Olympus IX-71 inverted microscope equipped with a 100x PlanApochromat objective (NA 1.4) was utilized for imaging both fluorescence and Nomarski Differential Interference Contrast (DIC) modalities. The GFP filter block was employed for fluorescence imaging (exc. 488 nm/em. 507 nm).

### Image Processing Macros

Four distinct macros were developed for ImageJ/Fiji to process the acquired images:

1. **MITO_MULTI_GLOBAL_THRESHOLDING.ijm:**

    - This macro preprocesses fluorescence images (**Fig. 1**) using [background subtraction](https://imagejdocu.list.lu/gui/process/subtract_background), outlier elimination, grayscale and binary morphology, and [Tubeness](https://www.longair.net/edinburgh/imagej/tubeness/) for enhanced visualization of mitochondrial filamentous structures.
    - A global thresholding method with predefined thresholds is applied, followed by the elimination of small objects using a [particle analyzer](https://imagej.net/imaging/particle-analysis).
    - The optimal segmented image is chosen by an expert based on appropriate thresholds (**Fig. 2**).
    - Usage: Open an **original, unprocessed fluorescence MIP**, e.g. "alpha_WT_control_pro_02.tif", in Fiji, then run the macro; it performs its own preprocessing. The **parameters** are `noiseSizeInPixels` (minimum retained object area, default **30 pixels²**) and `numTresh` (default **20**, generating intensity thresholds from 1 to 20 on the 8-bit Tubeness image). To extend the threshold range, increase `numTresh` to an integer no greater than 255. Ensure that the **Gray Morphology** and **Tubeness** plugins are installed. Masks and the enhanced image are saved in the input directory; a **"Macro completed"** message confirms completion. Save a copy of the selected mask with the matching `_SEG_` filename for subsequent analysis.

2. **MITO_PREPROCESSING.ijm:**

   - This macro preprocesses fluorescence images (**Fig. 1**) to make subsequent segmentation of mitochondrial fragments  using [MitoSegNet](https://github.com/mitosegnet) easier. It applies simply [background subtraction](https://imagejdocu.list.lu/gui/process/subtract_background) and outlier elimination.
   - Usage: Run the macro and select the folder containing **original, single-plane grayscale MIP TIFF images** with `_pro_` in their names; images do not need to be opened beforehand. The macro processes matching files directly in that folder, copies the unchanged originals to **Originals/** with the suffix `_orig.tif`, and saves processed 8-bit images under their original filenames. Defaults are a rolling-ball radius of **15 pixels** and bright-outlier removal with radius **1 pixel** and threshold **1**; conversion to 8-bit uses each processed image's minimum and maximum. Files with existing original backups or incompatible dimensions are skipped. A **"Batch preprocessing completed"** message summarizes the results; a detailed log is saved in **Originals/**. Use processed images for segmentation only.

3. **MITO_CELL_BASED_ANALYSIS.ijm:**

    - This macro utilizes fluorescent images, mitochondrial segmentation, and corresponding DIC images (**Fig. 6**). DIC images are used to relate segmented mitochondria and their parameters to individual cells.
    - Processes the segmented image with [local thickness](https://imagej.net/imagej-wiki-static/Local_Thickness) (**Fig. 4**) analysis and [skeletonization](https://imagej.net/plugins/skeletonize3d) (**Fig. 5**) to determine mitochondrial thickness, lengths, branching, [Branching Factor](https://www.tandfonline.com/doi/full/10.3109/01913123.2015.1054013), and Filamentous Factor, see also below.
    - Segments yeast cells using the [Cellpose](https://github.com/MouseLand/cellpose) (**Fig. 7**) method and generates stacks containing segmentation, skeletons, and local thickness for each cell.
    - Various measurements are taken within each cell, including skeleton-based length, average thickness and intensity, mitochondrial area, circularity, and cell area. **Average Intensity** is measured along each skeleton in the original fluorescence MIP; **Length** is estimated as the number of skeleton pixels multiplied by pixel width.
    - Supporting images and numerical results are saved as TIF and CSV files, respectively, for verification.
    - Requires [Anaconda](https://www.anaconda.com/), a working [Cellpose](https://github.com/MouseLand/cellpose) environment, the [Cellpose wrapper](https://github.com/BIOP/ijl-utilities-wrappers) for Fiji (including its `ExecutePythonInConda` launcher), Fiji BeanShell support, **Local Thickness**, **Skeletonize (2D/3D)**, and **Analyze Skeleton (2D/3D)**. The macro uses the **default model of the selected Cellpose environment**, without a version/model selection or an explicit `--pretrained_model` argument. It requests GPU processing and a diameter of 69 pixels; record the tested Cellpose version, since defaults and segmentation results may differ between versions.
    - Usage: Run the macro, enter **pixelWidth** and **pixelHeight** in µm and select the **Cellpose environment folder** in the dialog, then select "alpha_WT_control_DIC_02.tif". **Square pixels are required** (`pixelWidth = pixelHeight`). One image triplet is processed per run. Calibration is applied before branch-length measurements; lengths and thicknesses are reported in µm and areas in µm². Results are stored in the DIC image directory. Import the CSV files into Excel using a comma as the separator. The analysis may take several minutes; a **"Cell-based analysis completed"** message confirms completion. Image windows and Results are closed at the end; reopen saved outputs for inspection. Synchronize Windows is opened only in debugging mode.
    
4.	**MITO_FRAGMENT_BASED_ANALYSIS.ijm:**

    - This macro processes all matching `_pro_` fluorescence and `_SEG_` binary image pairs in a selected folder. All filename parts outside these case-sensitive markers must match exactly. Missing, ambiguous, or incompatible pairs are skipped and recorded in the log.
    - It conducts an analysis of area, intensities, perimeter, lengths of the major and minor axes of the fitted ellipse, and [morphological characteristics](https://imagej.net/ij/docs/menus/analyze.html#set) – circularity, aspect ratio, roundness, solidity – of individual mitochondria on the entire image and per each fragment.
    - Results, including TIFF images with fragment outlines (`*-Outlines.tif`) and CSV measurements (`*-Intensities.csv`), are saved in a new **Fragment_Analysis/** subfolder (or **Fragment_Analysis_2/**, etc. if it already exists). **Mean**, **Min**, and **Max** are measured in the original fluorescence image within each fragment; **Angle** is the orientation of the fitted ellipse.
    - Usage: Run the macro, enter **pixelWidth** and **pixelHeight** in µm in the dialog, then select the folder containing the image pairs. Images do not need to be opened beforehand. The calibration applies to the entire batch. A **"Batch analysis completed"** message reports processed and skipped entries; see **Analysis_Log.txt** in the output folder for details.

Naming convention of our images:

- Experiment Name_DIC_number.tif = DIC image;
- Experiment Name_pro_number.tif = fluorescence image with mitochondria;
- Experiment Name_SEG_number.tif = segmented mitochondria image; 

For compatibility with all four macros, use a shared prefix and a **two-digit image number** immediately before `.tif`, e.g. `sample_DIC_02.tif`, `sample_pro_02.tif`, and `sample_SEG_02.tif`. Images must be single-plane, spatially aligned, and have matching dimensions; segmentation masks must be 8-bit with white objects (255) on a black background (0).

**Intensity measurements:** Both analysis macros read the `_pro_` file. In a **separate analysis folder**, place a copy of the original fluorescence MIP from **Originals/** alongside its matching segmentation and, for cell-based analysis, DIC image. Remove `_orig` from the copy's filename (e.g. `sample_pro_02_orig.tif` → `sample_pro_02.tif`) and preserve the backup unchanged. Intensities are not background-corrected; quantitative comparisons require consistent acquisition settings and consideration of background fluorescence. Fragment-wide mean intensity and skeleton-based average intensity are different measurements.

### Comparison of Segmentation Methods:

Mitochondrial segmentation was conducted using two different methods: global thresholding (**Fig. 2**) and [MitoSegNet](https://github.com/mitosegnet) (**Fig. 3**). The purpose was to showcase the advantages of deep learning for precise mitochondrial segmentation. However, the original MitoSegNet model did not entirely succeed with the provided images, prompting the annotation and retraining of the model.

For practical experimentation, a triplet of images (mitochondria, MitoSegNet segmentation, and DIC) is attached to the webpage. All macros for global thresholding and subsequent mitochondrial analyses are available for testing. Before applying [MitoSegNet](https://github.com/mitosegnet), use MITO_PREPROCESSING.ijm on original fluorescence MIPs. For MitoS prediction, use only processed `_pro_` TIFF images; exclude DIC images, masks, and original backups from the prediction input. Additionally, the [retrained MitoSegNet model (MitoS_yeast)](https://owncloud.cesnet.cz/index.php/s/cnDFxKV5wVLLTt5), cca 355 MB, is provided.

The corresponding program for mitochondria segmentation that can utilize this model is [MitoS](https://github.com/MitoSegNet/MitoS-segmentation-tool).

### Computation of Branching and Filamentous Factors

- **Branching Factor** = the SUM of all branch points per skeleton / the SUM of all end points per skeleton.

    It is evaluated for the whole image of segmented mitochondria, before separation into individual cells, using the resulting "*-Branching-Factor.csv" file. Apply summing all values in the column C-Junctions (=branch points), the same in the column D-End-point voxels (=end points) and compute the value. The higher the Branching Factor, the higher richness and mutual interconnections of mitochondria; the lower the Branching Factor, the shorter and more separated mitochondria in the image.

- **Filamentous Factor** = (the SUM of all branch points per skeleton + the SUM of branches per skeleton) / the SUM of all end points per skeleton.

    Apply summing all values in the column B-Branches, the same for C-Junctions (=branch points) and for D-End-point voxels (=end points) and compute the value. The higher the Filamentous Factor, the more connected filaments the mitochondria network has got.

Branch lengths in this table use the pixel calibration entered in the macro and are reported in µm. Both factors are dimensionless and are calculated from the exported counts; they are undefined if the total number of endpoints is zero.

### Comments on Dead Cells

In DIC images, occasional dead cells are observed, potentially impacting the analysis. These cells appear as darker objects (**Fig. 6**). In fluorescence images, similar objects mimic the original cells but with reduced intensity and lacking recognized mitochondria. Deep learning-based segmentation and global thresholding both fail to detect these shapes due to lack of training or intensity below the threshold. As a result, images containing dead cells are excluded from the analysis.

### A newly retrained model and data

According to reviewer's comment and proposal the original MitoSegNet model was also retrained using another set of data: The new model (MitoS_yeast_CB) was trained to detect mitochondria of wild-type and fission mutant dnm1∆ from noisy background (dead cells, unlabelled cells exhibiting autofluorescence and artificial spots on background). Both the model and image examples can be found [here](https://owncloud.cesnet.cz/index.php/s/cnDFxKV5wVLLTt5?path=%2FMitoS_yeast_CB_model_and_corresponding_images).

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
