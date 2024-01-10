# Morphology_Yeast_Mitochondria
Analysis of morphology of healthy and treated *mitochondria* in images acquired by a widefield fluorescence microscope (WF) to distinguish differences between the controls (both wild and treated) and the experiments (both wild and treated as well). The analysis was done with and the pictures were created and provided by Dr. Jana Vojtová, [Laboratory of Cell Reproduction, Institute of Microbiology of the Czech Academy of Sciences, Prague, Czech Republic](https://mbucas.cz/en/research/biology-of-the-cell-and-bioinformatics/laboratory-of-cell-reproduction/))

**Macro for [ImageJ/Fiji](https://fiji.sc/).**

### Short description

As **inputs** the macro takes two images: 1. fluorescence image of mitochondria; 2. DIC image of corresponding yeast cells of the same field of view. DIC images are used to relate selected mitochondrial parameters to individual cells.

A **microscope** used for the acquisition of both modalities: Olympus IX-71 inverted microscope with a 100x PlanApochromat objective (NA 1.4), GFP filter block exc. max. 488, em. max. 507; Nomarski Differential Interference Contrast (DIC) mode.

We have developed **two macros** for processing images of mitochondria.

- **The first macro** *(název)* preprocesses fluorescence images using [(Subtract background)](https://imagejdocu.list.lu/gui/process/subtract_background), eliminating outliers, applying grayscale and binary morphology to reduce data inhomogeneity, and a [Tubeness filter](https://www.longair.net/edinburgh/imagej/tubeness/) to enhance the visualization quality of filamentous structures (mitochondria). Subsequently, a global thresholding method with a predefined range of thresholds is applied to the image, and a particle analyzer is utilized to eliminate small resulting objects. The best segmented image with an appropriate threshold is then selected by an expert, see **Fig. 2** *(thresholds applied)*.

Fig. 1: **Fluorescence images** of mitochondria (WILD Control/WILD Treated):
![Fluo-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/0dbbf106-dc14-40f9-930c-456b582716d5)

Fig. 2: Fluorescence images of mitochondria **segmented** by **global thresholding** *(Macro...)*:
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
