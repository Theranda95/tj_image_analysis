// =========================================================================================================================//
//Therande Jashari 
//Last Updated Oct 20, 2025 
//This macro is updated from 240814 myh experiments
//It makes a max z-project for two channels at specific slices, then does binary masks 

//It reads only .lif files from the Leica Scopes and it prompts a window where you can pick the series (images)
//within one .lif file that you want to process 

// to adapt it to your needs you can change the channel you want the mask on, threshold and so on below or 
//contact me for questions/help 
// =========================================================================================================================//

// Specify the .lif file directly 
path = File.openDialog("Select a File");
name = File.getName(path);
//print(name);

// Open the Bio-Formats plugin
run("Bio-Formats Macro Extensions");

// Set the path for the Bio-Formats Extension
Ext.setId(path);

// Get the number of series in the .lif file
Ext.getSeriesCount(sC);
//print("Total series count: " + sC);

// Create a dialog to select the range of series
Dialog.create("Select range");
Dialog.addMessage("The file you selected contains " + sC + " image series\nPlease specify the range you wish to access.");
Dialog.addNumber("Begin", 1);
Dialog.addNumber("End", sC);
Dialog.show();
begin = Dialog.getNumber();
end = Dialog.getNumber();

// Prompt the user to select the directory for the output folder for Images and Results 
output_base_dir = getDirectory("Choose a Directory");

// --- Create subdirectories for each channel ---
makeSubdirs("mf20_analysis");
makeSubdirs("hoechst_analysis");


// Loop through each series in the specified range
for (i = begin; i <= end; i++) {
    // Series indexing is 0-based
    Ext.setSeries(i - 1); 
    // Get the series name
	Ext.getSeriesName(seriesName);
	//print(seriesName);
    
    // Open the current series
    run("Bio-Formats", 
        "open=" + path + " color_mode=Default " + 
        "view=Hyperstack stack_order=XYCZT series_list=" + i);
    
    // Call the function to process both channels 
    flatstack(seriesName);
    
    // Close all windows after processing
    run("Close All");
}


// === FUNCTION DEFINITIONS ===

// --- Create standard subdirectories for each channel ---
function makeSubdirs(tag) {
    base = output_base_dir + "/" + tag + "/";
    File.makeDirectory(base);

    eval(tag + "_stacks_dir = base + 'maxproj/';");
    eval(tag + "_masks_dir  = base + 'masks/';");
    eval(tag + "_results_dir = base + 'summary/';");
    eval(tag + "_roi_dir = base + 'rois/';");

    File.makeDirectory(eval(tag + "_stacks_dir"));
    File.makeDirectory(eval(tag + "_masks_dir"));
    File.makeDirectory(eval(tag + "_results_dir"));
    File.makeDirectory(eval(tag + "_roi_dir"));
}



// --- Process both channels for a single series ---
function flatstack(seriesName) {
    run("Split Channels");

    // Channel 1 (Hoechst)
    processChannel("C1-", "c1_hoechst", seriesName, "Huang");

    // Channel 2 (MF20)
    processChannel("C2-", "c2_mf20", seriesName, "Mean");

    roiManager("reset");
}

// --- Process one channel with custom threshold ---
function processChannel(prefix, tag, seriesName, thresholdMethod) {
    chan_name = prefix + name + " - " + seriesName;
    selectWindow(chan_name);

    // Duplicate only slices 15–17
    run("Duplicate...", "title=Temp_" + tag + " duplicate range=15-17");

    // Perform SUM projection (use [Max Intensity] if preferred)
    run("Z Project...", "projection=[Sum Slices]");

    proj_name = "SUM_" + tag + "_" + seriesName + "_s15-17.tif";
    save_path = eval(tag + "_stacks_dir") + proj_name;
    saveAs("Tiff", save_path);

    // Apply channel-specific threshold and make mask
    selectWindow(proj_name);
    setAutoThreshold(thresholdMethod + " dark");
    setOption("BlackBackground", true);
    run("Convert to Mask");

    // Save mask
    mask_name = "Mask_" + tag + "_" + seriesName + "_s15-17.tif";
    saveAs("Tiff", eval(tag + "_masks_dir") + mask_name);

    // Analyze Particles and save results
    run("Analyze Particles...", "display summarize add composite");

    summary_name = seriesName + "_" + tag + "_summary.csv";
    selectWindow("Summary");
    saveAs("Results", eval(tag + "_results_dir") + summary_name);
    run("Close");

    // Save ROIs
    roi_save_path = eval(tag + "_roi_dir") + "Mask_" + tag + "_" + seriesName + "_s15-17_rois.zip";
    roiManager("Save", roi_save_path);

    // Cleanup
    roiManager("delete");
    run("Close All");
}


