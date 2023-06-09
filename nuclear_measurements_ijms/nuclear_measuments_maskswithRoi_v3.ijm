// =========================================================================================================================//
// * Identify the directory to access files * 
dir = getDirectory("Choose Input Directory"); // Select input directory
//dir_roi = getDirectory("Choose ROI Directory"); // Select roi directory
//print(dir);

input_dir = dir;
output_dir =  File.getParent(dir) + "/outputs/"; //Path to making the directory 
File.makeDirectory(output_dir); // Making the output folder 
print(output_dir)

list = getFileList(input_dir); //Get the files from a folder 
num_files = lengthOf(list);

//roi_list = getFileList(dir_roi, ".roi");
//roi_num_files = lengthOf(roi_list); 
//setBatchMode(true); Turning this on does not remove the roi selections from the images

for (i = 0; i < num_files; i++) {
	file_name = list[i];
	nd2_index = indexOf(file_name, ".nd2");
	if (nd2_index != -1){
		mask (file_name, input_dir, output_dir);
	}
	   
}

function mask (file, input_dir,  output_dir) {
	name = File.getName(file); // get filename 
	index_nd2 = indexOf(name, ".nd2");
    image_name = substring(name, 0, index_nd2);
	open(name);
	selectWindow(name);
	run("Split Channels");
	close();
	close();
	//close();
	
	
	c1_name = "C1-" + name;
	selectWindow(c1_name);
	run("Z Project...", "projection=[Max Intensity]");
	selectWindow(c1_name);
	close();
	
	
	index_nd2 = indexOf(name, ".nd2");
	image_name = substring(file_name, 0, index_nd2);
	max_name = "MAX_" + image_name + ".tif";

	full_max_name = output_dir + max_name;
    saveAs("Tiff", full_max_name);
    selectWindow(max_name);
    setOption("ScaleConversions", true);
	run("8-bit");
	run("Gaussian Blur...", "sigma=1");
    run("Auto Local Threshold", "method=Phansalkar radius=30 parameter_1=0.25 parameter_2=0.5 white");
    run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
    run("Remove Outliers...", "radius=3 threshold=50 which=Bright");
    run("Fill Holes");
    run("Grays");
    
    roi_file_name = input_dir + "/" + image_name + ".roi";
    if (File.exists(roi_file_name)) {
    	roiManager("reset");
    	roiManager("Open", roi_file_name);
    	roiManager("show all");
    	roiManager("draw");
     }

	
	mask_name = "MASK_" + image_name + ".tif";
	full_mask_name = output_dir + mask_name;
	saveAs("Tiff",  full_mask_name);
	run("Close All");
}
//setBatchMode(false);	