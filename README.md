# Morphology_Yeast_Mitochondria
Analysis of morphology of healthy and treated *mitochondria* in images acquired by a widefield fluorescence microscope (WF) to distinguish differences between the controls (both wild and treated) and the experiments (both wild and treated as well). The analysis was done with and the pictures were created and provided by Dr. Jana Vojtová, [Laboratory of Cell Reproduction, Institute of Microbiology of the Czech Academy of Sciences, Prague, Czech Republic](https://mbucas.cz/en/research/biology-of-the-cell-and-bioinformatics/laboratory-of-cell-reproduction/))

**Macros for [ImageJ/Fiji](https://fiji.sc/).**

### Short description

Two images are **inputs** to the analysis: 1. fluorescence image of mitochondria, **Fig. 1**; 2. DIC image of corresponding yeast cells of the same field of view, **Fig. 6**. DIC images are used to relate segmented mitochondria and their parameters to individual cells.

A **microscope** used for the acquisition of both modalities: Olympus IX-71 inverted microscope with a 100x PlanApochromat objective (NA 1.4), GFP filter block exc. max. 488, em. max. 507; Nomarski Differential Interference Contrast (DIC) mode.

We have developed **two macros** for processing images of mitochondria.

- **The first macro** *(název)* preprocesses fluorescence images using [(Subtract background)](https://imagejdocu.list.lu/gui/process/subtract_background), eliminating outliers, applying grayscale and binary morphology to reduce data inhomogeneity, and [Tubeness](https://www.longair.net/edinburgh/imagej/tubeness/) to enhance the visualization quality of filamentous structures (mitochondria). Subsequently, a global thresholding method with a predefined range of thresholds is applied to the image, and a particle analyzer is utilized to eliminate small resulting objects. The best segmented image with an appropriate threshold is then selected by an expert, see **Fig. 2** (thresholds applied: left=4, right=13).
-  As an entry into **the second macro** *(nazev)*, fluorescent images with mitochondria, their segmentation, and corresponding DIC images are utilized. The segmented image undergoes two processes: the application of [Local thickness](https://imagej.net/imagej-wiki-static/Local_Thickness), **Fig. 4**, to determine the thickness of mitochondria and [skeletonization](https://imagej.net/plugins/skeletonize3d), **Fig. 5**, to ascertain the lengths, branching, and determination of [Branching Factor](https://www.tandfonline.com/doi/full/10.3109/01913123.2015.1054013) and Filamentous Factor of the mitochondria. Subsequently, the image of yeast cells from DIC is segmented using the [Cellpose](https://github.com/MouseLand/cellpose) method, **Fig. 7**, individual cell masks are created, and from these, stacks are generated containing segmentation, skeletons, and local thickness of these cells. Using these stacks, measurements are taken for the lengths of all mitochondria in each cell, their average thickness, average intensity, mitochondrial area, circularity, and cell area. All supporting images, i.e., resulting Cellpose segmentation, generated masks, and stacks with local thickness, skeletons, and mitochondrial segmentation (TIF), and numerical results, i.e., the skeleton analysis result for calculating the Branching and Filamentous Factor and the morphological analysis result of all cells (CSV), are finally saved to disk for verification.

For comparison, we **segmented mitochondria using two different methods**. The first method involved global thresholding *(macro)*, as shown in Fig. 2, while the second method utilized [MitoSegNet](https://www.cell.com/iscience/fulltext/S2589-0042(20)30793-8), depicted in Fig. 3. The aim was to demonstrate the advantages of deep learning for more precise mitochondrial segmentation. However, the original model of the MitoSegNet project did not entirely succeed with our images. Therefore, we annotated our images, retrained the model, and here on this page *(file name)*, we offer it for potential further utilization with similar data.

Fig. 1: **Fluorescence images** of mitochondria (WILD Control/WILD Treated):
![Fluo-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/0dbbf106-dc14-40f9-930c-456b582716d5)

Fig. 2: Fluorescence images of mitochondria **segmented** by **global thresholding** *(Macro...)*, (thresholds applied: left=4, right=13):
![GlobThresh-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/b8bbfd60-1801-4afb-8544-99fadbb0f552)

Fig. 3: Fluorescence images of mitochondria **segmented** by the retrained model *(Model...)* of [**MitoSegNet**](https://www.cell.com/iscience/fulltext/S2589-0042(20)30793-8):
![MitoSegNet-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/1d5e7f21-1311-4fee-9c70-5adfa75cf7e8)

Fig. 4: [**Local thickness**](https://imagej.net/imagej-wiki-static/Local_Thickness) images created from data segmented by **MitoSegNet**, see Fig. 3 :
![LocalThickness-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/854982f6-bd8c-42d1-a7ea-b46b9734b035)

Fig. 5: [**Skeletons**](https://imagej.net/plugins/skeletonize3d) created from data segmented by **MitoSegNet**, see Fig. 3:
![Skeleton-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/e3204a1e-dd76-4f1e-8003-b63d48388288)

Fig. 6: **DIC** images of yeast cells:
![DIC-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/c1503bd4-4bee-4a52-8c4d-9b3188400a00)

Fig. 7: DIC images of yeast cells **segmented** by [**Cellpose**](https://github.com/MouseLand/cellpose):
![Cellpose-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/c8bccab0-f102-4702-9492-e65a092c75c3)

...
