// =========================================================================================================================//
// * Identify the directory to access files * 
dir = getDirectory("Choose Input Directory"); // Select input directory
dir_roi = getDirectory("Choose ROI Directory"); // Select roi directory
//print(dir);

output_dir = dir + "23.05.02_Output/"; //Path to making the directory 
File.makeDirectory(output_dir); // Making the output folder 
//print(output_dir)


list = getFileList(dir); //Get the files from a folder 
num_files = lengthOf(list); 
//setBatchMode(true);

for (i = 0; i < num_files; i++) {
	file_name = list[i];
	mask (file_name, dir);
}

function mask (file, dir) {
	name = File.getName(file); // get filename 
	open(name);
	selectWindow(name);
	run("Split Channels");
	close();
	close();
	close();
	
	c1_name = "C1-" + name;
	selectWindow(c1_name);
	run("Z Project...", "projection=[Max Intensity]");
	run("Gaussian Blur...", "sigma=1");
	selectWindow(c1_name);
	close();
	
	
	index_nd2 = indexOf(name, ".nd2");
	image = substring(file_name, 0, index_nd2);
	max_name = "MAX_" + image + ".tif";
	full_max_name = output_dir + max_name;
    saveAs("Tiff", full_max_name);
    selectWindow(max_name);
    setAutoThreshold("RenyiEntropy dark no-reset");
    setOption("BlackBackground", true);
    run("Convert to Mask");
    run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
    run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
    run("Fill Holes");
    
    roiManager("reset");
    roiManager("Open", dir_roi + image + ".roi");
    roiManager("show all");
    roiManager("draw");
    
//	roiList = getFileList(roiDir);
//    
//    for (j = 0; j < roiList.length; j++) {
//    	roiManager("reset");
//        roiManager("Open", roiDir + roiList[j]);
//        roiManager("show all");
//        roiManager("Draw");
//    }
	
	mask_name = "MASK_" + image + ".tif";
	full_mask_name = output_dir + mask_name;
	saveAs("Tiff",  full_mask_name);
	run("Close All");
}
//setBatchMode(false);	