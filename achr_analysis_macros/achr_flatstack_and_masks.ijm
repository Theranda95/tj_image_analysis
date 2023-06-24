// =========================================================================================================================//
// * Identify the directory to access files * 
dir = getDirectory("Choose input Directory"); // Select the directory
//print(dir);

list = getFileList(dir); //Get the files from a folder 

output_dir = dir + "23.06.21_achr_stacks_masks/"; //Path to making the directory 
File.makeDirectory(output_dir); // Making the output folder 
//print(output_dir)

num_files = lengthOf(list); 
//call("ij.Prefs.set", "BioFormats.showDialog", "false");
//setBatchMode(true);

for (i = 0; i < num_files; i++) {
	file_name = list[i];
	flatstack(file_name, dir);
}

function flatstack (file, dir) {
	name = File.getName(file); // get filename 
	open(name);
	selectWindow(name);
	run("Split Channels");
	//close();
	//close();
	//close();
	
	c3_name = "C3-" + name;
	selectWindow(c3_name);
	run("Z Project...", "stop=25 projection=[Max Intensity]");
	//run("Gaussian Blur...", "sigma=1");
	//selectWindow(c3_name);
	//close();
	
	
	index_nd2 = indexOf(name, ".nd2");
	image = substring(file_name, 0, index_nd2);
	max_name = "MAX_" + image + ".tif";
	full_max_name = output_dir + max_name;
    saveAs("Tiff", full_max_name);
    selectWindow(max_name);
    setAutoThreshold("Yen dark no-reset");
    setOption("BlackBackground", true);
    run("Convert to Mask");
    //run("Fill Holes");
	
	mask_name = "MASK_" + image + ".tif";
	full_mask_name = output_dir + mask_name;
	saveAs("Tiff",  full_mask_name);
	run("Analyze Particles...", "size=5-Infinity display exclude summarize add");
	summary = image + "_summary.csv";
	results = image + "_results.csv";
	selectWindow("Results");
	saveAs("Results", output_dir + results);
	selectWindow("Results");
	run("Close");
	selectWindow("Summary");
	saveAs("Results", output_dir + summary);
	selectWindow(summary);
	run("Close All");
	roiManager("delete");
	run("Close All");
	
}
	
	//run("Close All");
//setBatchMode(false);	