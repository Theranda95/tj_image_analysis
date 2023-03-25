// * Initialize the macro * 
waitForUser("mulTIFFly", "Let's mulTIFFly your image for analysis!");
Dialog.create("mulTIFFly Notes");
	Dialog.addMessage("This macro helps with the following proceses:\nStep 1: Converting files to a single position hyperstack\n \nStep 2: Pre-process images to create analysis files.\n \nStep 3: Create images for nuclear analysis (Bob).\n \nStep 4: Create images for NMJ analysis (NMJ morphometrics plugin).");
	Dialog.addMessage("");
	Dialog.show();