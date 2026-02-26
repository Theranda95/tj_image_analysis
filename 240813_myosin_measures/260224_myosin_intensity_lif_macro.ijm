// =========================================================================================================================//
// Therande Jashari
// Created: February 24, 2026
// Combined myosin intensity measurement macro for MF20 (C2), MYH3 (C3), and MYH8 (C4)
// from a Leica .lif file.
//
// Per-series pipeline:
//   1. C2 MF20 max projection + subtracted mask (Huang minus Minimum)
//   2. Sum projections for C2, C3, C4
//   3. Intensity measurements on sum projections using C2 mask ROIs
//   4. C4 MYH8 max projection + Huang mask
//
// Channels: C2 = MF20 (555nm), C3 = MYH3 (488nm), C4 = MYH8 (647nm)
// Outputs: projections (TIFF), masks (TIFF), ROIs (ZIP), results (CSV)
// =========================================================================================================================//

// Hardcoded path to .lif file
path = "/Users/therandajashari/Documents/experiments_2026/260112_wt_characterization_2/260224_myh3_myh8_analysis_n3/260224_wt26_myh3488_mf20555_myh8647.lif";
name = File.getName(path);

// Open Bio-Formats plugin
run("Bio-Formats Macro Extensions");
Ext.setId(path);

// Get number of series
Ext.getSeriesCount(sC);

// Hardcoded series range (all series)
begin = 1;
end = sC;

// Output base directory
output_base_dir = "/Users/therandajashari/Documents/experiments_2026/260112_wt_characterization_2/260224_myh3_myh8_analysis_n3/";

// Create output subdirectories
mf20_maxproj_dir = output_base_dir + "260224_mf20_maxproj/";
File.makeDirectory(mf20_maxproj_dir);

mf20_subs_masks_dir = output_base_dir + "260224_mf20_subs_masks/";
File.makeDirectory(mf20_subs_masks_dir);

mf20_sumproj_dir = output_base_dir + "260224_mf20_sumproj/";
File.makeDirectory(mf20_sumproj_dir);

mf20_rois_dir = output_base_dir + "260224_mf20_rois/";
File.makeDirectory(mf20_rois_dir);

myh3_sumproj_dir = output_base_dir + "260224_myh3_sumproj/";
File.makeDirectory(myh3_sumproj_dir);

myh8_maxproj_dir = output_base_dir + "260224_myh8_maxproj/";
File.makeDirectory(myh8_maxproj_dir);

myh8_masks_dir = output_base_dir + "260224_myh8_masks/";
File.makeDirectory(myh8_masks_dir);

myh8_sumproj_dir = output_base_dir + "260224_myh8_sumproj/";
File.makeDirectory(myh8_sumproj_dir);

myh8_rois_dir = output_base_dir + "260224_myh8_rois/";
File.makeDirectory(myh8_rois_dir);

results_dir = output_base_dir + "260224_results/";
File.makeDirectory(results_dir);

// Loop through each series in the specified range
for (i = begin; i <= end; i++) {
    Ext.setSeries(i - 1);
    Ext.getSeriesName(seriesName);
    print("Processing series " + i + ": " + seriesName);

    run("Bio-Formats",
        "open=" + path + " color_mode=Default " +
        "view=Hyperstack stack_order=XYCZT series_list=" + i);

    processImage(seriesName);

    run("Close All");
}

print("Done.");

// ─────────────────────────────────────────────────────────────────────────────
function processImage(seriesName) {

    // Split into individual channel windows
    run("Split Channels");

    // Channel window names
    c2_name = "C2-" + name + " - " + seriesName;
    c3_name = "C3-" + name + " - " + seriesName;
    c4_name = "C4-" + name + " - " + seriesName;

    // ── Step 1: C2 MF20 — Max projection + subtracted mask ──────────────────

    selectWindow(c2_name);
    run("Z Project...", "projection=[Max Intensity]");

    // Save max projection
    max_name = "MAX_c2_mf20_" + seriesName + ".tif";
    saveAs("Tiff", mf20_maxproj_dir + max_name);

    // Duplicate for second mask
    selectWindow(max_name);
    run("Duplicate...", " ");
    duplicate_name = "MAX_c2_mf20_" + seriesName + "-1.tif";

    // Mask 1: Minimum threshold on original
    selectWindow(max_name);
    setAutoThreshold("Minimum dark");
    setOption("BlackBackground", true);
    run("Convert to Mask");

    // Mask 2: Huang threshold on duplicate
    selectWindow(duplicate_name);
    setAutoThreshold("Huang dark");
    setOption("BlackBackground", true);
    run("Convert to Mask");

    // Subtract Minimum mask from Huang mask
    imageCalculator("Subtract create", duplicate_name, max_name);

    // Save subtracted mask
    selectImage("Result of " + duplicate_name);
    mask_name = "Mask_c2_mf20_" + seriesName + ".tif";
    saveAs("Tiff", mf20_subs_masks_dir + mask_name);

    // Measure area on subtracted mask
    setThreshold(1, 255);
    run("Set Measurements...", "area display redirect=None decimal=3");
    run("Analyze Particles...", "display summarize add");

    // Save MF20 mask summary CSV
    if (isOpen("Results")) {
        selectWindow("Results");
        run("Close");
    }
    if (isOpen("Summary")) {
        summary_csv = seriesName + "_mf20_mask_summary.csv";
        selectWindow("Summary");
        saveAs("Results", results_dir + summary_csv);
        selectWindow(summary_csv);
        run("Close");
    }

    // ROIs are kept in manager for Step 3

    // ── Step 2: Sum projections (C2, C3, C4) ────────────────────────────────

    // C2 sum projection
    selectWindow(c2_name);
    run("Z Project...", "projection=[Sum Slices]");
    c2_sum_name = "SUM_c2_mf20_" + seriesName + ".tif";
    saveAs("Tiff", mf20_sumproj_dir + c2_sum_name);

    // C3 sum projection
    selectWindow(c3_name);
    run("Z Project...", "projection=[Sum Slices]");
    c3_sum_name = "SUM_c3_myh3_" + seriesName + ".tif";
    saveAs("Tiff", myh3_sumproj_dir + c3_sum_name);

    // C4 sum projection
    selectWindow(c4_name);
    run("Z Project...", "projection=[Sum Slices]");
    c4_sum_name = "SUM_c4_myh8_" + seriesName + ".tif";
    saveAs("Tiff", myh8_sumproj_dir + c4_sum_name);

    // ── Step 3: Intensity measurements using C2 mask ROIs ───────────────────

    if (roiManager("count") > 0) {
        run("Set Measurements...", "area mean modal min integrated display redirect=None decimal=3");

        // Measure C2 sum projection
        selectWindow(c2_sum_name);
        roiManager("Deselect");
        roiManager("Measure");
        if (isOpen("Results")) {
            selectWindow("Results");
            saveAs("Results", results_dir + seriesName + "_mf20_intensity.csv");
            selectWindow("Results");
            run("Close");
        }

        // Measure C3 sum projection
        selectWindow(c3_sum_name);
        roiManager("Deselect");
        roiManager("Measure");
        if (isOpen("Results")) {
            selectWindow("Results");
            saveAs("Results", results_dir + seriesName + "_myh3_intensity.csv");
            selectWindow("Results");
            run("Close");
        }

        // Measure C4 sum projection
        selectWindow(c4_sum_name);
        roiManager("Deselect");
        roiManager("Measure");
        if (isOpen("Results")) {
            selectWindow("Results");
            saveAs("Results", results_dir + seriesName + "_myh8_intensity.csv");
            selectWindow("Results");
            run("Close");
        }

        // Save C2 mask ROIs
        roiManager("Save", mf20_rois_dir + "Mask_c2_mf20_" + seriesName + "_rois.zip");
        roiManager("Delete");
    } else {
        print("  No ROIs from MF20 mask for: " + seriesName + " — intensity measurements skipped.");
    }

    // ── Step 4: C4 MYH8 — Max projection + Huang mask ──────────────────────

    selectWindow(c4_name);
    run("Z Project...", "projection=[Max Intensity]");

    // Save max projection
    myh8_max_name = "MAX_c4_myh8_" + seriesName + ".tif";
    saveAs("Tiff", myh8_maxproj_dir + myh8_max_name);

    // Huang threshold → mask
    selectWindow(myh8_max_name);
    setAutoThreshold("Huang dark");
    setOption("BlackBackground", true);
    run("Convert to Mask");

    // Save mask
    myh8_mask_name = "Mask_c4_myh8_" + seriesName + ".tif";
    saveAs("Tiff", myh8_masks_dir + myh8_mask_name);

    // Measure area on MYH8 mask
    run("Set Measurements...", "area display redirect=None decimal=3");
    run("Analyze Particles...", "display summarize add");

    // Save MYH8 mask summary CSV
    if (isOpen("Results")) {
        selectWindow("Results");
        run("Close");
    }
    if (isOpen("Summary")) {
        myh8_summary_csv = seriesName + "_myh8_mask_summary.csv";
        selectWindow("Summary");
        saveAs("Results", results_dir + myh8_summary_csv);
        selectWindow(myh8_summary_csv);
        run("Close");
    }

    // Save MYH8 ROIs
    if (roiManager("count") > 0) {
        roiManager("Save", myh8_rois_dir + "Mask_c4_myh8_" + seriesName + "_rois.zip");
        roiManager("Delete");
    } else {
        print("  No ROIs from MYH8 mask for: " + seriesName);
    }
}
