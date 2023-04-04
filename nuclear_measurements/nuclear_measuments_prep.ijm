// =========================================================================================================================
// * Identify the directory to access files * 
dir = getDirectory("Choose input Directory"); // Select the directory
print(dir);
list = getFileList(dir); 

output_dir = dir + "/outputs/";
File.makeDirectory(output_dir);
print(output_dir)

num_files = lengthOf(list);
for (i = 0; i < num_files; i++) {
	write(list[i]);
}