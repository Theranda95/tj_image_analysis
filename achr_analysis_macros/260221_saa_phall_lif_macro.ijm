// =========================================================================================================================//
// Therande Jashari
// Created: February 22, 2026
// Analyzes phalloidin channel (C4, 647nm) from a Leica .lif file:
//   - Skips the first 3 series
//   - Z-projects all slices (Max Intensity)
//   - Huang threshold → binary mask → Analyze Particles (size 3–Infinity)
//   - Saves: max projection TIFFs, mask TIFFs, ROI zips, Results CSVs, Summary CSVs
// =========================================================================================================================//

// Hardcoded path to .lif file
path = "/Users/therandajashari/Documents/experiments_2026/260112_wt_characterization_2/260221_saa_achr_phall/260220_ncrm1_untag_saa488_achr555_phall647.lif";
name = File.getName(path);

// Open the Bio-Formats plugin
run("Bio-Formats Macro Extensions");
Ext.setId(path);

// Get total number of series in the file
Ext.getSeriesCount(sC);
print("Total series in file: " + sC);

// Skip the first 3 series
begin = 4;
end = sC;

// Output base directory
output_base_dir = "/Users/therandajashari/Documents/experiments_2026/260112_wt_characterization_2/260221_saa_achr_phall/";

// Create output subdirectories
maxproj_dir = output_base_dir + "260221_saa_phall_maxproj/";
File.makeDirectory(maxproj_dir);

masks_dir = output_base_dir + "260221_saa_phall_masks/";
File.makeDirectory(masks_dir);

roi_dir = output_base_dir + "260221_saa_phall_rois/";
File.makeDirectory(roi_dir);

results_dir = output_base_dir + "260221_saa_phall_results/";
File.makeDirectory(results_dir);

// Loop through series, skipping the first 3
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

    // Select channel 4 (phalloidin 647nm)
    c4_name = "C4-" + name + " - " + seriesName;
    selectWindow(c4_name);

    // Get total number of slices for full Z-projection
    nSlicesVal = nSlices;

    // Z-project all slices (Max Intensity)
    run("Z Project...", "start=1 stop=" + nSlicesVal + " projection=[Max Intensity]");

    // Save the max projection as TIFF
    max_name = "MAX_c4_phall_" + seriesName + ".tif";
    saveAs("Tiff", maxproj_dir + max_name);

    // Apply Huang threshold and convert to binary mask
    selectWindow(max_name);
    setAutoThreshold("Huang dark no-reset");
    setOption("BlackBackground", true);
    run("Convert to Mask");

    // Save the mask as TIFF
    mask_name = "MASK_c4_phall_" + seriesName + ".tif";
    saveAs("Tiff", masks_dir + mask_name);

    // Set measurements to area only
    run("Set Measurements...", "area display redirect=None decimal=3");

    // Analyze Particles: size 3–Infinity, exclude edge particles, display & summarize
    run("Analyze Particles...", "size=3-Infinity display summarize add");

    // Save Results CSV — only if particles were found (window may not exist if count = 0)
    results_name = seriesName + "_results.csv";
    if (isOpen("Results")) {
        selectWindow("Results");
        saveAs("Results", results_dir + results_name);
        selectWindow("Results");
        run("Close");
    } else {
        print("  No particles found for: " + seriesName + " — Results CSV skipped.");
    }

    // Save Summary CSV
    summary_name = seriesName + "_summary.csv";
    if (isOpen("Summary")) {
        selectWindow("Summary");
        saveAs("Results", results_dir + summary_name);
        selectWindow(summary_name);
        run("Close");
    } else {
        print("  Summary window not found for: " + seriesName + " — Summary CSV skipped.");
    }

    // Save ROIs — only if any were added
    if (roiManager("count") > 0) {
        roi_save_path = roi_dir + "c4_phall_" + seriesName + "_rois.zip";
        roiManager("Save", roi_save_path);
        roiManager("Delete");
    } else {
        print("  No ROIs to save for: " + seriesName);
    }
}
