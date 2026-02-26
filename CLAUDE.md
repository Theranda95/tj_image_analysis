# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a collection of **ImageJ Macro Language (.ijm)** scripts for automated fluorescence microscopy image analysis of Drosophila larval muscle tissue. The macros process multi-channel images from Leica (.lif) and Nikon (.nd2) microscopes to quantify protein localization (AChR, Titin, Myosin, MRTF) at neuromuscular junctions (NMJs) and nuclei.

There is no build system. Macros are run directly in **Fiji/ImageJ** via `Plugins > Macros > Run` or by dragging a `.ijm` file into the Fiji window.

## Running Macros

All macros are run interactively inside Fiji/ImageJ. They prompt the user for:
1. A `.lif` input file (or directory of images)
2. Series range (start/end) — since .lif files contain multiple image series
3. An output base directory

They create subdirectories automatically (e.g., `072024_achr_maxproj/`, `072024_achr_masks/`, `072024_achr_rois/`, `072024_achr_results/`).

## StarDist Nuclear Segmentation (Python)

The nuclear segmentation pipeline uses a separate Python environment. Setup (done once per machine):

```bash
# For Intel Macs:
conda create -n stardist_env python=3.10
conda activate stardist_env
pip install tensorflow stardist

# For Apple Silicon (M1/M2/M3):
conda create -y -n stardist_env_m1 python=3.9
conda activate stardist_env_m1
conda install -c apple tensorflow-deps
pip install tensorflow-macos tensorflow-metal stardist
```

Run the segmentation script (from within the cloned repo directory):
```bash
python 2D_Stardist_prediction.py -d 'images'
```

The StarDist repo being used is: https://github.com/lisambrster/DrosophilaLarvalMuscleNuclei2DStardistSegmentation

## Architecture & Conventions

### Standard Pipeline (all batch macros follow this pattern)

```
.lif file → Bio-Formats plugin → Split Channels → Z-Project (Max or Sum)
         → Auto-Threshold → Convert to Mask → Analyze Particles
         → Save: maxproj/ (TIFF), masks/ (TIFF), rois/ (ZIP), results/ (CSV)
```

### Key Conventions in .ijm Files

- **Bio-Formats** is used to open `.lif` files: `run("Bio-Formats Macro Extensions")` + `Ext.setId(path)`
- Series are 0-indexed internally (`Ext.setSeries(i - 1)`) but 1-indexed in dialog prompts
- Window names follow the pattern `"C2-" + filename + " - " + seriesName`
- Thresholding methods vary by channel/protein: `RenyiEntropy`, `Huang`, `Triangle`, `Mean`, `Yen`
- ROIs are saved as `.zip` archives via `roiManager("Save", path)`
- Results and Summary tables must be explicitly selected and closed after saving — failure to close causes data from subsequent images to append to the same table (known issue in older macros)

### Folder Organization by Analysis Type

| Directory | Purpose |
|---|---|
| `achr_analysis_macros/` | Acetylcholine receptor (AChR) channel analysis from .lif files |
| `240813_myosin_measures/` | Myosin (MF20, MYH8) intensity and mask analysis |
| `251020_mrtf_analysis_macro/` | MRTF-A/B transcription factor localization |
| `nuc_achr_dist_measurements/` | Distance between nuclei and NMJ structures |
| `nuclear_measurements_ijms/` | Nuclear segmentation (IJM + Python/StarDist) |
| `tutorials/` | Basic IJM language reference |

### File Naming Conventions

- Macro files are prefixed with date: `MMYYYY_` or `YYMMDD_` (e.g., `072024_`, `251020_`)
- Output directories embed the date prefix matching their source macro
- ROI files are matched to images by stripping the `.nd2` extension and appending `.roi`

## Known Issues

- **Summary table not closing**: Older macros don't close the Summary window between images, causing result rows to accumulate across series. The fix is to `selectWindow("Summary"); run("Close");` after each save (as done in `072024_achr_lif_macro.ijm`).
- **Titin/AChR composite macro** (`titin_achr_flatstack.ijm`) is incomplete — noted in commit history.
- Output directory names are sometimes hardcoded with date prefixes; update these when adapting a macro for a new experiment.
