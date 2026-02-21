// =========================================================================================================================//
//Therande Jashari 
//Last Updated August 15, 2024 
//This macro uses ROIs from a folder as well as projections (from a second folder)
//then measures values: intensities within the threshold, area etc. 
//It reads .roi files from a folder as well as .tif
		//There are three prompts 
			//1. Pick the folder containing sum projection images you want to measure 
			//2. Pick the folder containing the roi's of interest to define the mask 
			//3. Pick the output folder where the results spreadsheets would be saved 
// to adapt it to your needs you can change the channel you want the mask on, threshold and so on below or 
//contact me for questions/help 
// =========================================================================================================================//

// Select the directory with the .tif max projections
tifDir = getDirectory("Choose directory with .tif images");
tifFiles = getFileList(tifDir); // Get the list of .tif files
//print(tifDir)

// Select the directory for .roi files
roiDir = getDirectory("Choose directory with .roi files"); 
roiFiles = getFileList(roiDir); // Get the list of .roi files
//(roiDir)

// Prompt the user to select the output directory for results  
output_base_dir = getDirectory("Choose a Directory");

// Construct the output directory path and name 
results_dir = output_base_dir + "/251030_mrtfa_intensity_res/"; // Path to making the directory
File.makeDirectory(results_dir); // Make the output folder


// Loop through each .tif file
for (i = 0; i < tifFiles.length; i++) {
    tifFile = tifFiles[i];
    
         if (endsWith(tifFile, ".tif")) {
        // Define the constant prefix and suffix in the .tif filename
        tifPrefix = "mtrfa_SUM_";
        tifSuffix = ".tif";
        // Extract the variable part (e.g., comb_d8_01) from the .tif filename
        tifMatch = substring(tifFile, lengthOf(tifPrefix), lastIndexOf(tifFile, tifSuffix));
        //print(tifMatch);
        
        
        // Find the corresponding ROI file
        for (j = 0; j < roiFiles.length; j++) {
            roiFile = roiFiles[j];
            
            if (endsWith(roiFile, ".zip")) {
            	// Define the constant prefix and suffix in the .zip filename
                roiPrefix = "mask_C1_hoechst_MAX_";
                roiSuffix = "_rois.zip";
                // Extract the matching part from the .zip file name
                roiMatch = substring(roiFile, lengthOf(roiPrefix), lastIndexOf(roiFile, roiSuffix));
            
            	 // Check if the extracted parts match
                if (tifMatch == roiMatch) {
                    // Open the .tif image
                    open(tifDir + tifFile);
                    
                
                	// Open and apply the ROI file
                	roiManager("Open", roiDir + roiFile);
                	run("Set Measurements...", "area mean modal min integrated area_fraction limit redirect=None decimal=3");
                	roiManager("Measure");

                	// Save the results to the output directory
                	saveAs("Results", results_dir + tifMatch + "_results.csv");
                	
                	// cleanup
					selectWindow("Results");
					run("Close");
                
               		// Close the image and clear the ROI Manager
                	close();
                	roiManager("Reset");
                
                	break; // Break out of the loop once the matching ROI is found
                }
            }
        }
    }
}
