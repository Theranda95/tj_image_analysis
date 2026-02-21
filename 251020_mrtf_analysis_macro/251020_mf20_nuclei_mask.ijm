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

// Select the directory containing the .tif files
input_dir = getDirectory("Choose Directory with .tif Files");

// Select the directory for the output folder for Images, Masks, ROIs, and Results
output_base_dir = getDirectory("Choose a Directory for Output");

// Construct output directories
masks_dir = output_base_dir + "/251030_masks_mf20/";
File.makeDirectory(masks_dir);

roi_dir = output_base_dir + "/251030_ROI_mf20/";
File.makeDirectory(roi_dir);

results_dir = output_base_dir + "/251030_summary_results_mf20/";
File.makeDirectory(results_dir);

// Define the threshold types for each channel (can be customized per channel)
//C1_threshold = "Default dark";  // Threshold method for channel 1
//C2_threshold = "Huang dark";    // Threshold method for channel 2

list = getFileList(input_dir);

// --- Loop over files ---
for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], ".tif")) {
        //print("Processing: " + list[i]);
        image_path = input_dir + list[i];
        open(image_path);

        // Get image name without extension
        imageName = File.getName(image_path);
        imageNamex = replace(imageName, ".tif", ""); //removing the ext 
		//print(imageName);
		
        // --- Split channels ---
        run("Split Channels");

        // Select channel 1 (Hoechst)
        selectWindow("C2-" + imageName); // Adjust if your naming differs
        //rename("C1_" + imageName);

// // --- Create mask for channel 1 ---
//        setAutoThreshold("Default dark"); // Adjust threshold method as needed
//        setOption("BlackBackground", true);
//        run("Convert to Mask");
        
        // --- Create mask for channel 2 ---
        setAutoThreshold("Li dark"); // Adjust threshold method as needed
        setOption("BlackBackground", true);
        run("Convert to Mask");

        // --- Save mask ---
        maskName = "mask_C2_mf20_" + imageName;
        saveAs("Tiff", masks_dir + maskName);

        // --- Analyze particles ---
        run("Set Measurements...", "area mean min centroid redirect=None decimal=3");
        run("Analyze Particles...", "display summarize add");
        
        // --- Save results and summary ---
        summaryPath = results_dir + imageNamex + "_summary.csv";
        saveAs("Results", summaryPath);

        // --- Save ROIs ---
        roiSavePath = roi_dir + "mask_mf20_" + imageNamex + "_rois.zip";
        roiManager("Save", roiSavePath);
        roiManager("delete");

        // --- Close all images and tables ---
        run("Close All");
        if (isOpen("Results")) close("Results");
        if (isOpen("Summary")) close("Summary");

        //print("Finished: " + imageName);
    }
}

//print("Batch processing complete!");

