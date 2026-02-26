// =========================================================================================================================//
// Therande Jashari
// Created: February 22, 2026
// Semi-automated sarcomere spacing measurement from channel 3 (SAA-488nm) of a Leica .lif file:
//   - Skips the first 3 series
//   - User selects the best Z-slice per series
//   - User draws lines across sarcomere bands (multiple per image, done when ready)
//   - Macro extracts intensity profiles (K-plots), detects peaks, measures sarcomere lengths
//   - Saves: K-plot PNGs, line ROI ZIPs, results CSVs
// =========================================================================================================================//

// ── Configurable parameters ──────────────────────────────────────────────────
line_width = 3;            // Line width for averaged intensity profile
smooth_window = 3;         // Moving average window size
min_peak_dist_um = 1.0;    // Minimum distance between peaks in um
min_peaks = 4;             // Minimum peaks to accept a measurement
max_peaks = 8;             // Maximum peaks to accept a measurement

// ── Paths ────────────────────────────────────────────────────────────────────
path = "/Users/therandajashari/Documents/experiments_2026/260112_wt_characterization_2/260221_saa_achr_phall/260220_ncrm1_untag_saa488_achr555_phall647.lif";
name = File.getName(path);

output_base_dir = "/Users/therandajashari/Documents/experiments_2026/260112_wt_characterization_2/260221_saa_achr_phall/";

// Create output subdirectories
kplot_dir = output_base_dir + "260222_saa_sarc_kplots/";
File.makeDirectory(kplot_dir);

roi_dir = output_base_dir + "260222_saa_sarc_rois/";
File.makeDirectory(roi_dir);

results_dir = output_base_dir + "260222_saa_sarc_results/";
File.makeDirectory(results_dir);

// ── Bio-Formats setup ────────────────────────────────────────────────────────
run("Bio-Formats Macro Extensions");
Ext.setId(path);

Ext.getSeriesCount(sC);
print("Total series in file: " + sC);

begin = 4;
end = sC;

// Global array used to return peak indices from findPeaks()
var gPeaks = newArray(0);

// ── Main loop ────────────────────────────────────────────────────────────────
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

print("Done — sarcomere measurements complete.");

// =============================================================================
// processImage — per-series workflow
// =============================================================================
function processImage(seriesName) {

    // Split into individual channel windows
    run("Split Channels");

    // Select channel 3 (SAA 488nm)
    c3_name = "C3-" + name + " - " + seriesName;
    selectWindow(c3_name);

    // Get pixel calibration
    getPixelSize(unit, pixelWidth, pixelHeight);
    if (unit == "pixels" || unit == "pixel") {
        print("  WARNING: No calibration found for " + seriesName + " — assuming 1 px = 1 um");
        pixelWidth = 1;
    }
    print("  Pixel size: " + pixelWidth + " " + unit);

    // ── Step 1: Manual Z-slice selection ─────────────────────────────────────
    waitForUser("Select Z-slice", "Series: " + seriesName +
        "\nScroll to the slice with the clearest sarcomere bands, then click OK.");
    sliceNum = getSliceNumber();
    print("  Selected slice: " + sliceNum);

    // Duplicate the chosen slice as working copy
    run("Duplicate...", "title=slice_orig");
    selectWindow("slice_orig");

    // Set line width for profile averaging
    run("Line Width...", "line=" + line_width);

    // Clear ROI Manager
    if (roiManager("count") > 0) {
        roiManager("Delete");
    }

    // Pre-compute min peak distance in pixels
    min_peak_dist_px = min_peak_dist_um / pixelWidth;

    // Open CSV file for this series
    csv_path = results_dir + seriesName + "_sarcomere_results.csv";
    csvFile = File.open(csv_path);
    print(csvFile, "Series,Line,Slice,nPeaks,Mean_Sarc_um,Peaks_um,Distances_um");

    // ── Step 2: User draws lines — loop until done ───────────────────────────
    lineCount = 0;
    measuring = true;

    while (measuring) {
        selectWindow("slice_orig");
        setTool("line");

        // Ask user to draw a line or finish
        waitForUser("Draw Line " + (lineCount + 1),
            "Series: " + seriesName +
            "\nLines measured so far: " + lineCount +
            "\n\nDraw a line across the sarcomere bands, then click OK." +
            "\nTo finish this series, click OK without drawing a line.");

        // Check if the user drew a line selection
        selType = selectionType();
        if (selType != 5) {
            // selectionType 5 = straight line; anything else means no line drawn
            if (lineCount == 0) {
                print("  No lines drawn for " + seriesName + " — skipping series.");
            } else {
                print("  Finished drawing — " + lineCount + " lines measured for " + seriesName);
            }
            measuring = false;
            continue;
        }

        lineCount++;

        // Save the line ROI to manager
        roiManager("Add");
        roiManager("select", roiManager("count") - 1);
        roiManager("Rename", "Line_" + lineCount);

        // Extract intensity profile along the user-drawn line
        profile = getProfile();
        nPoints = profile.length;

        if (nPoints < 10) {
            print("  Line " + lineCount + ": profile too short (" + nPoints + " points) — skipping");
            continue;
        }

        // Smooth the profile (moving average)
        smoothed = smoothProfile(profile, smooth_window);

        // Compute threshold for peak detection: mean + 0.3 * stdDev
        Array.getStatistics(smoothed, sMin, sMax, sMean, sStdDev);
        minHeight = sMean + 0.3 * sStdDev;

        // Find peaks
        findPeaks(smoothed, min_peak_dist_px, minHeight);
        peaks = gPeaks;
        nPeaks = peaks.length;

        // Validate peak count
        if (nPeaks < min_peaks || nPeaks > max_peaks) {
            print("  Line " + lineCount + ": " + nPeaks + " peaks (outside " +
                  min_peaks + "-" + max_peaks + " range) — measurement saved but flagged");
        }

        // Calculate peak positions in um and peak-to-peak distances
        if (nPeaks >= 2) {
            peakPositions_um = newArray(nPeaks);
            for (p = 0; p < nPeaks; p++) {
                peakPositions_um[p] = peaks[p] * pixelWidth;
            }

            distances_um = newArray(nPeaks - 1);
            distSum = 0;
            for (d = 0; d < nPeaks - 1; d++) {
                distances_um[d] = (peaks[d+1] - peaks[d]) * pixelWidth;
                distSum = distSum + distances_um[d];
            }
            meanSarc = distSum / (nPeaks - 1);

            print("  Line " + lineCount + ": " + nPeaks + " peaks, mean sarcomere = " + d2s(meanSarc, 3) + " um");

            // Save K-plot as PNG
            savePlot(seriesName, lineCount, smoothed, peaks, pixelWidth, nPeaks, meanSarc);

            // Write CSV row
            peakStr = "";
            for (p = 0; p < nPeaks; p++) {
                if (p > 0) peakStr = peakStr + ";";
                peakStr = peakStr + d2s(peakPositions_um[p], 3);
            }
            distStr = "";
            for (d = 0; d < nPeaks - 1; d++) {
                if (d > 0) distStr = distStr + ";";
                distStr = distStr + d2s(distances_um[d], 3);
            }

            print(csvFile, seriesName + "," + lineCount + "," + sliceNum + "," + nPeaks + "," +
                  d2s(meanSarc, 3) + "," + peakStr + "," + distStr);
        } else {
            print("  Line " + lineCount + ": only " + nPeaks + " peak(s) found — cannot compute distances");
            // Still save the K-plot for inspection
            savePlot(seriesName, lineCount, smoothed, peaks, pixelWidth, nPeaks, 0);
            print(csvFile, seriesName + "," + lineCount + "," + sliceNum + "," + nPeaks + ",NA,NA,NA");
        }
    }

    File.close(csvFile);
    print("  Saved results to: " + csv_path);

    // ── Step 3: Save line ROIs ───────────────────────────────────────────────
    if (roiManager("count") > 0) {
        roi_save_path = roi_dir + "c3_sarc_" + seriesName + "_line_rois.zip";
        roiManager("Save", roi_save_path);
        roiManager("Delete");
    } else {
        print("  No ROIs to save for: " + seriesName);
    }

    // Close the working slice
    if (isOpen("slice_orig")) {
        selectWindow("slice_orig");
        close();
    }
}

// =============================================================================
// smoothProfile — moving average filter
// =============================================================================
function smoothProfile(profile, window) {
    n = profile.length;
    result = newArray(n);
    halfW = floor(window / 2);
    for (i = 0; i < n; i++) {
        sum = 0;
        count = 0;
        for (j = i - halfW; j <= i + halfW; j++) {
            if (j >= 0 && j < n) {
                sum = sum + profile[j];
                count++;
            }
        }
        result[i] = sum / count;
    }
    return result;
}

// =============================================================================
// findPeaks — local maxima detection with minimum distance and height
//   Sets global gPeaks array (IJM functions cannot return arrays via return)
// =============================================================================
function findPeaks(profile, minDist, minHeight) {
    gPeaks = newArray(0);
    n = profile.length;
    for (j = 2; j < n - 2; j++) {
        if (profile[j] > profile[j-1] && profile[j] > profile[j+1]
            && profile[j] > profile[j-2] && profile[j] > profile[j+2]
            && profile[j] > minHeight) {
            // Check minimum distance from last accepted peak
            // (IJM does not short-circuit ||, so use nested ifs)
            addPeak = true;
            if (gPeaks.length > 0) {
                if ((j - gPeaks[gPeaks.length - 1]) < minDist) {
                    addPeak = false;
                }
            }
            if (addPeak) {
                gPeaks = Array.concat(gPeaks, j);
            }
        }
    }
}

// =============================================================================
// savePlot — create K-plot PNG with intensity curve and peak markers
// =============================================================================
function savePlot(seriesName, lineIdx, profile, peaks, pixelWidth, nPeaks, meanSarc) {
    n = profile.length;

    // Build x-axis in um
    xVals = newArray(n);
    for (k = 0; k < n; k++) {
        xVals[k] = k * pixelWidth;
    }

    // Build peak coordinate arrays for markers
    peakX = newArray(nPeaks);
    peakY = newArray(nPeaks);
    for (k = 0; k < nPeaks; k++) {
        peakX[k] = peaks[k] * pixelWidth;
        peakY[k] = profile[peaks[k]];
    }

    // Create the plot
    titleStr = "Sarcomere Profile — " + seriesName + " Line " + lineIdx;
    if (meanSarc > 0) {
        titleStr = titleStr + " (mean: " + d2s(meanSarc, 2) + " um)";
    }
    Plot.create(titleStr, "Distance (um)", "Intensity");
    Plot.setColor("blue");
    Plot.add("line", xVals, profile);
    if (nPeaks > 0) {
        Plot.setColor("red");
        Plot.add("circles", peakX, peakY);
    }
    Plot.setColor("black");
    if (meanSarc > 0) {
        Plot.addText("Peaks: " + nPeaks + "  Mean sarc: " + d2s(meanSarc, 2) + " um", 0.05, 0.05);
    } else {
        Plot.addText("Peaks: " + nPeaks + "  (insufficient for measurement)", 0.05, 0.05);
    }
    Plot.show();

    // Save as PNG
    plot_name = seriesName + "_line" + lineIdx + "_kplot.png";
    saveAs("PNG", kplot_dir + plot_name);
    close();
}
