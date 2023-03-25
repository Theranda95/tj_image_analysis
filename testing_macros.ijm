// * Initialize the macro * 
waitForUser("TJ macro - Preprocessing");
Dialog.create("Preprocess for Nuclei Analysis Notes");
	Dialog.addMessage("This macro helps with the following proceses:\nStep 1: Converting files to TIFF separate channels \n \nStep 2: Pre-process images to create analysis files.\n \nStep 3: Create images for nuclear analysis.\n");
	Dialog.addMessage("");
	Dialog.show();
	
	
// =========================================================================================================================
// * Array of file types that can be imported for nuclei analysis * 
filetypes = newArray("Hyperstack per position", "TIFF per position", "ND2 per position", "CZI", "LIF", "Single Z slice per position", "Individual channels per position",  "Multiposition tiff");
channelnum = newArray("2", "3", "4");
chan = newArray("None", "Phalloidin", "Zasp", "Hoechst", "Brp", "Lamin", "pMad", "HRP", "Dlg", "Fibrillarin", "H3K9Ac/me")
third = newArray("Brp", "Lamin", "pMad");
projection = newArray("Sum Slices", "Max Intensity");
answer = newArray("Yes", "No");