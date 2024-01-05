# Morphology_Yeast_Mitochondria
Analysis of morphology of healthy and treated *mitochondria* in images acquired by a widefield fluorescence microscope (WF) to distinguish differences between the controls (both wild and treated) and the experiments (both wild and treated as well). The analysis was done with and the pictures were created and provided by Dr. Jana Vojtová, [Laboratory of Cell Reproduction, Institute of Microbiology of the Czech Academy of Sciences, Prague, Czech Republic](https://mbucas.cz/en/research/biology-of-the-cell-and-bioinformatics/laboratory-of-cell-reproduction/))

**Macro for [ImageJ/Fiji](https://fiji.sc/).**

### Short description

As **inputs** the macro takes two images: 1. fluorescence image of mitochondria; 2. DIC image of corresponding yeast cells of the same field of view. DIC images are used to relate selected mitochondrial parameters to individual cells.

A **microscope** used for the acquisition of both modalities: Olympus IX-71 inverted microscope with a 100x PlanApochromat objective (NA 1.4), GFP filter block exc. max. 488, em. max. 507; Nomarski Differential Interference Contrast (DIC) mode.

Fluorescence images of mitochondria (WILD Control/WILD Treated):
![Fluo-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/0dbbf106-dc14-40f9-930c-456b582716d5)

Fluorescence images of mitochondria segmented by global thresholding thresholding:
![GlobThresh-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/b8bbfd60-1801-4afb-8544-99fadbb0f552)

DIC images of yeast cells (WILD Control/WILD Treated):
![DIC-WILD-Pair](https://github.com/LMCF-IMG/Morphology_Yeast_Mitochondria/assets/63607289/c1503bd4-4bee-4a52-8c4d-9b3188400a00)

dic seg by cellpose
...
