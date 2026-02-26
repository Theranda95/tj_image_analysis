# Running ImageJ Macros with Claude Code

## Prerequisites

- **Fiji/ImageJ** installed at `/Applications/Fiji.app`
- Fiji's bundled Java is x64-only — on Apple Silicon Macs, Fiji must be launched via `open -a` (not headless mode)

## How to Ask Claude to Run a Macro

### Step 1: Prepare the macro

Before running, make sure the macro has two paths hardcoded (not interactive dialogs):

1. **Input data path** — the `.lif` file location
2. **Output directory** — where results should be saved

If the macro uses `getDirectory()` or `File.openDialog()`, ask Claude to replace those lines with hardcoded paths. Example:

```
Replace: output_base_dir = getDirectory("Choose output directory");
With:    output_base_dir = "/full/path/to/your/output/folder/";
```

### Step 2: Ask Claude to launch Fiji

Use this prompt format:

```
Run the macro [path/to/macro.ijm] using Fiji.
Data path: /full/path/to/your/data.lif
Output directory: /full/path/to/output/
```

Claude will:
1. Edit the macro to hardcode your data and output paths
2. Launch Fiji with the macro using:
   ```bash
   open -a /Applications/Fiji.app --args -macro "/full/path/to/macro.ijm"
   ```

### Step 3: Monitor in Fiji

The macro runs inside the Fiji GUI. Check progress in Fiji's **Log window**, which prints messages like `Processing series 4: <seriesName>`.

## Why Not Headless Mode?

These macros use GUI operations (`selectWindow`, `roiManager`, `Split Channels`) and Fiji's bundled Java on this machine is x64, which doesn't load natively on Apple Silicon. The `open -a` approach uses macOS's Rosetta translation and launches the full GUI, which handles both issues.

## Example: Running the AChR Analysis Macro

The macro `260221_saa_achr_lif_macro.ijm` was run with:

- **Data**: `/Users/therandajashari/Documents/experiments_2026/260112_wt_characterization_2/260221_saa_achr_phall/260220_ncrm1_untag_saa488_achr555_phall647.lif`
- **Output**: `/Users/therandajashari/Documents/experiments_2026/260112_wt_characterization_2/260221_saa_achr_phall/`

### What the macro does

1. Opens the `.lif` file via Bio-Formats
2. Skips the first 3 series, processes series 4 onward
3. For each series:
   - Splits channels, selects C2 (AChR 555nm)
   - Z-projects slices 7–34 (Max Intensity)
   - Applies RenyiEntropy threshold and converts to binary mask
   - Runs Analyze Particles (size 3–Infinity) with measurements: area, circularity, solidity, Feret's diameter, roundness, major axis, minor axis
4. Saves outputs to four subdirectories:

| Folder | Contents |
|---|---|
| `260221_saa_achr_maxproj/` | Max projection TIFFs |
| `260221_saa_achr_masks/` | Binary mask TIFFs |
| `260221_saa_achr_rois/` | ROI zip files |
| `260221_saa_achr_results/` | Results CSVs + Summary CSVs |

### Parameters to change for a new experiment

| Parameter | Location in macro | Current value |
|---|---|---|
| Input `.lif` path | Line 12 (`path = ...`) | `260220_ncrm1_untag_saa488_achr555_phall647.lif` |
| Output directory | Line 28 (`output_base_dir = ...`) | `260221_saa_achr_phall/` |
| Series to skip | Line 24 (`begin = ...`) | `4` (skips first 3) |
| Z-project range | Line 71 (`start=... stop=...`) | Slices 7–34 |
| Threshold method | Line 79 (`setAutoThreshold(...)`) | `RenyiEntropy` |
| Particle size filter | Line 91 (`size=...`) | `3-Infinity` |
| Output folder prefixes | Lines 31, 34, 37, 40 | `260221_saa_achr_` |

## Quick Reference Prompt

Copy and adapt this when asking Claude to run a new macro:

```
Run this macro with Fiji: [macro path]
Hardcode these paths:
  - Data: [path to .lif file]
  - Output: [path to output directory]
```
