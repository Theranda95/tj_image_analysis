// =========================================================================================================================//
//Therande Jashari 
//Last Updated August 3, 2024 

//This is a version of the previous macro but here I am merging two channels (without z-project) and saving them 

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
sarc_merges_dir = output_base_dir + "/082024_saa_ttn_merge/"; // Path to making the directory
File.makeDirectory(sarc_merges_dir); // Making the output folder

//results_dir = output_base_dir + "/072024_ttn_results/"; 
//File.makeDirectory(results_dir); 

//masks_dir = output_base_dir + "/072024_ttn_masks/"; 
//File.makeDirectory(masks_dir); 

//roi_dir = output_base_dir + "/072024_ttn_rois/"; 
//File.makeDirectory(roi_dir); 



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
    //define channel 3(saa) and channel 4(ttn): name and seriesName was defined above 
        c3_name = "C3-" + name + " - " + seriesName;
        c4_name = "C4-" + name + " - " + seriesName;
    //merge the channels 
    selectWindow(c4_name);
	run("Merge Channels...", "c1=[" + c3_name + "] c2=[" + c4_name + "] create");
	
	//renaming and saving the merged image as tif
	selectImage("Composite");
	max_name = "c3_saa_c4_ttn_" + seriesName + ".tif";
	save_path = sarc_merges_dir + max_name;
    saveAs("Tiff", save_path);  
 }   