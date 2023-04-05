// =========================================================================================================================//
// * Identify the directory to access files * 
dir = getDirectory("Choose input Directory"); // Select the directory
print(dir);
list = getFileList(dir); 

output_dir = dir + "outputs/";
File.makeDirectory(output_dir);
print(output_dir)

num_files = lengthOf(list);
for (i = 0; i < num_files; i++) {
	file_name = list[i];
	flatstack(file_name, dir);
}

function flatstack (file, dir) {
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
	
	selectWindow(c1_name);
	close();
	
	
	index_nd2 = indexOf(name, ".nd2");
	image = substring(file_name, 0, index_nd2);
	max_name = "MAX_" + image + ".tif";
	full_max_name = output_dir + max_name  ;
    saveAs("Tiff", full_max_name);
    selectWindow(max_name);
    setAutoThreshold("Default dark no-reset");
    setOption("BlackBackground", true);
    run("Convert to Mask");
    run("Fill Holes");
	run("Watershed");
	
	mask_name = "MASK_" + image + ".tif";
	full_mask_name = output_dir + mask_name;
	saveAs("Tiff",  full_mask_name);
}
