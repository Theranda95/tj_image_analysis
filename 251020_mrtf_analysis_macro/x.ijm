// Macro: Split and Save Channel 3 and 4
// Reads all .tif files, splits channels, and saves C3 & C4 separately

// Select the directory containing the .tif files
input_dir = getDirectory("Choose Directory with .tif Files");

// Select the directory for the output folder for Images, Masks, ROIs, and Results
output_base_dir = getDirectory("Choose a Directory for Output");

// Construct output directories
mrtfa_dir = output_base_dir + "/251030_sum_mrtfa/";
File.makeDirectory(mrtfa_dir);

mrtfb_dir = output_base_dir + "/251030_sum_mrtfb/";
File.makeDirectory(mrtfb_dir);

list = getFileList(input_dir);

// --- Loop over files ---
for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], ".tif")) {
        //print("Processing: " + list[i]);
        image_path = input_dir + list[i];
        open(image_path);

        // Get image name without extension
         imageName = File.getName(image_path);

        // --- Split channels ---
        run("Split Channels");
        
         // Save channel 3 
        selectWindow("C3-" + imageName);
        saveAs("Tiff", mrtfa_dir + "mtrfa_" + imageName);
        close();
       
       
        // Save channel 4 
        selectWindow("C4-" + imageName);
        saveAs("Tiff", mrtfb_dir + "mtrfb_" + imageName);
        close();
    }
}
run("Close All");