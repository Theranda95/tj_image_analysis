// =========================================================================================================================//
//Therande Jashari 
//Last Updated August 13, 2024 
//This macro is updated from 072024_achr_lif_macro and makes a max z-project, then binary masks with two different autothreshold
// in duplicate images and SUBTRACT the mask 1 from mask 2 - in batch
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

// Construct the output directory path and name 
stacks_dir = output_base_dir + "/082024_mf20_maxproj/"; // Path to making the directory
File.makeDirectory(stacks_dir); // Making the output folder

results_dir = output_base_dir + "/082024_mf20_sum/"; 
File.makeDirectory(results_dir); 

masks_dir = output_base_dir + "/082024_mf20_subs_masks/"; 
File.makeDirectory(masks_dir); 

roi_dir = output_base_dir + "/082024_mf20_rois/"; 
File.makeDirectory(roi_dir); 

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
    
    // Call the function to process the current series
    flatstack(seriesName);
    
    // Close all windows after processing
    run("Close All");
}

function flatstack(seriesName) {
    // Split channels 
        run("Split Channels");
    //pick channel 2: name and seriesName was defined above 
        c2_name = "C2-" + name + " - " + seriesName;
	selectWindow(c2_name);
	
	//Making a MAX Projection on all the z-slices 
	run("Z Project...", "projection=[Max Intensity]");
	
	//renaming the max porjection and save as tif
	max_name = "MAX_c2_mf20_" + seriesName + ".tif";
	save_path = stacks_dir + max_name;
    saveAs("Tiff", save_path); 
    
 	//Duplicate 
 	selectWindow(max_name);
 	run("Duplicate...", " ");
 	duplicate_name = "MAX_c2_mf20_" + seriesName + "-1.tif";
 
 	//creating the first binary mask 
    selectWindow(max_name);
    setAutoThreshold("Minimum dark");
    setOption("BlackBackground", true);
    run("Convert to Mask");
    
    //creating the second binary mask 
    selectWindow(duplicate_name);
    setAutoThreshold("Huang dark");
	setOption("BlackBackground", true);
    run("Convert to Mask");

	//subtract the first mask from the second 
	imageCalculator("Subtract create", duplicate_name, max_name);
       
 	//saving the subtracted mask as a tif file
 	selectImage("Result of " + duplicate_name);
 	mask_name = "Mask_c2_mf20_" + seriesName + ".tif";
	mask_save_path = masks_dir + mask_name;
	saveAs("Tiff",  mask_save_path);
	
	run("Analyze Particles...", "display summarize add composite");
	
	summary_name = seriesName + "_summary.csv";
	//results_name = seriesName + "_results.csv";
	//save results spreadsheet 
	//selectWindow("Results");
	//saveAs("Results", results_dir + results_name);
	// cleanup
	selectWindow("Results");
	run("Close");
	//save summary spreadsheet
	selectWindow("Summary");
	saveAs("Results", results_dir + summary_name);
	// cleanup
	selectWindow(summary_name);
	run("Close");
	
	 // save ROIs
    roi_save_path = roi_dir + "Mask_c2_mf20_" + seriesName + "_rois.zip";
    roiManager("Save", roi_save_path);
    
    // cleanup
    roiManager("delete");
 }   


