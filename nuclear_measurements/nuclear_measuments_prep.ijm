// =========================================================================================================================
// * Identify the directory to access files * 
//dir = getDirectory("Choose input Directory"); // Select the directory
//print(dir);
//list = getFileList(dir); 
//
//output_dir = dir + "/outputs/";
//File.makeDirectory(output_dir);
//print(output_dir)
//
//num_files = lengthOf(list);
//for (i = 0; i < num_files; i++) {
//	write(list[i]);
//	file_name = list[i];
//	dir_name = dir;
//	flatstack(file_name, dir_name);
//}
//
//function flatstack (file, dir) {
//	print(file);
//	print(dir);
//}

variable = "file1";
print(variable);


output = dir + variable;
print(output);


first_name = "Jorge";
last_name = "Roldan";

get_full_name(first_name, last_name);

function get_full_name(first, last) {
	full_name = first + " " +  last;
	print(full_name);
}