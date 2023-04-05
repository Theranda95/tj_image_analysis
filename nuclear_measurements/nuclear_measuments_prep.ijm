// =========================================================================================================================
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
	
	max_name = output_dir + "out1.tif";
    saveAs("Tiff", max_name);
}

