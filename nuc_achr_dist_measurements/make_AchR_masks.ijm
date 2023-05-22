
// Pick the folder with input files
dir = getDirectory("Choose Input Directory"); 

//Create an output folder in the parent folder of input files 
input_dir = dir;
output_dir = File.getParent(dir) + "/outputs/"; //giving the path to making the directory 
File.makeDirectory(output_dir); 

list = getFileList(input_dir);
num_files = lengthOf(list); 

//setBatchMode(true);

for (i = 0; i < num_files; i++) {
	file_name = list[i];
	flatstack(file_name, dir);
}

function flatstack (file, dir) {
	name = File.getName(file); // get filename 
	open(name);
	selectWindow(name);
	setAutoThreshold("Triangle dark no-reset");
    setOption("BlackBackground", true);
    run("Convert to Mask");
    run("Fill Holes");
    
 
	image = substring(file_name, 4);
    mask_name = "MASK_" + image;
	full_mask_name = output_dir + mask_name;
	saveAs("Tiff",  full_mask_name);
	run("Close All");
}

//setBatchMode(false);