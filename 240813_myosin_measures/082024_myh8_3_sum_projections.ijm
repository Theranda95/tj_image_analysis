// =========================================================================================================================//
//Therande Jashari 
//Last Updated August 15, 2024 
//This macro is updated from 072024_achr_lif_macro and makes a sum z-project for two of the channels and saves them.

//It reads only .lif files from the Leica Scopes and it prompts a window where you can pick the series (images)
//within one .lif file that you want to process 

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
myh3_dir = output_base_dir + "/082024_myh3_sumproj/"; // Path to making the directory
File.makeDirectory(myh3_dir); // Making the output folder

myh8_dir = output_base_dir + "/082024_myh8_sumproj/"; 
File.makeDirectory(myh8_dir); 

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
    //pick channel 3: name and seriesName was defined above 
        c3_name = "C3-" + name + " - " + seriesName;
	
	//Making a SUM Projection on all the z-slices for channel 3  
	selectWindow(c3_name);
	run("Z Project...", "projection=[Sum Slices]");
	
	//renaming the sum porjection and save as tif
	sum_name_c3 = "SUM_c3_myh3_" + seriesName + ".tif";
	save_path_c3 = myh3_dir + sum_name_c3;
	saveAs("Tiff", save_path_c3);
	run("Close");
	
	//pick channel 2: name and seriesName was defined above 
	c4_name = "C4-" + name + " - " + seriesName;
	
	//Making a SUM Projection on all the z-slices for channel 4
	selectWindow(c4_name);
	run("Z Project...", "projection=[Sum Slices]");
	
	//renaming the sum porjection and save as tif
	sum_name_c4 = "SUM_c4_myh8_" + seriesName + ".tif";
	
	save_path_c4 = myh8_dir + sum_name_c4;
    saveAs("Tiff", save_path_c4); 
	
 }   


