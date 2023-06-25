// =========================================================================================================================//
// * Identify the directory to access files * 
dir = getDirectory("Choose input Directory"); // Select the directory
//print(dir);

list = getFileList(dir); //Get the files from a folder 

output_dir = dir + "23.06.26_titin_flatstack/"; //Path to making the directory 
File.makeDirectory(output_dir); // Making the output folder 
//print(output_dir)

num_files = lengthOf(list); 
//call("ij.Prefs.set", "BioFormats.showDialog", "false");
setBatchMode(true);

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
	close();

	
	c2_name = "C2-" + name;
	selectWindow(c2_name);
	run("Z Project...", "stop=60 projection=[Max Intensity]");
	//selectWindow(c3_name);
	//close();
	
	
	index_nd2 = indexOf(name, ".nd2");
	image = substring(file_name, 0, index_nd2);
	max_name = "MAX_" + image + ".tif";
	full_max_name = output_dir + max_name;
    saveAs("Tiff", full_max_name);
    close();
}
