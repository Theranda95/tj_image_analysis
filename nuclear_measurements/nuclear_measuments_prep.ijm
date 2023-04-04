// =========================================================================================================================
// * Identify the directory to access files * 

dir = getDirectory("Choose input Directory"); // Select the directory
list = getFileList(dir); 

write(list[0])

num_files = lengthOf(list);
write(num_files)

for (i = 0; i < num_files; i++) {
	write(list[i]);
}