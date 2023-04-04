// * MulTIFFly Analysis * 
// Written by Briana Christophers
// Created: October 2021 on FIJI Version 2.3.0/1.53f (2021-09-13)
// Last updated: November 12, 2021
// Purpose: Convert any image file type into usable images that can be used for analysis in Bob or NMJ morphometrics


// * Initialize the macro * 
waitForUser("mulTIFFly", "Let's mulTIFFly your image for analysis!");
Dialog.create("mulTIFFly Notes");
	Dialog.addMessage("This macro helps with the following proceses:\nStep 1: Converting files to a single position hyperstack\n \nStep 2: Pre-process images to create analysis files.\n \nStep 3: Create images for nuclear analysis (Bob).\n \nStep 4: Create images for NMJ analysis (NMJ morphometrics plugin).");
	Dialog.addMessage("");
	Dialog.show();

// =========================================================================================================================
// * Array of file types that can be imported to MulTIFFly * 
filetypes = newArray("Hyperstack per position", "TIFF per position", "ND2 per position", "CZI", "LIF", "Single Z slice per position", "Individual channels per position",  "Multiposition tiff");
channelnum = newArray("2", "3", "4");
chan = newArray("None", "Phalloidin", "Zasp", "Hoechst", "Brp", "Lamin", "pMad", "HRP", "Dlg", "Fibrillarin", "H3K9Ac/me")
third = newArray("Brp", "Lamin", "pMad");
projection = newArray("Sum Slices", "Max Intensity");
answer = newArray("Yes", "No");

// * First dialog box that allows for indicating which conversions to complete *
setJustification("left");

Dialog.create("mulTIFFly Parameters");
	Dialog.addMessage("Step 1: File type conversion");
	Dialog.addChoice("What file type is your input?", filetypes);
	Dialog.addRadioButtonGroup("How many channels are in your image?", channelnum, 1, 3, "4");
	Dialog.addChoice("Channel 1", chan, "None");
	Dialog.addChoice("Channel 2", chan, "None");
	Dialog.addChoice("Channel 3", chan, "None");
	Dialog.addChoice("Channel 4", chan, "None");
	Dialog.addRadioButtonGroup("Display type", projection, 2, 1, "Sum Slices");
	Dialog.show();

type = Dialog.getChoice();
channels = Dialog.getRadioButton(); 
c1 = Dialog.getChoice();
c2 = Dialog.getChoice();
c3 = Dialog.getChoice();
c4 = Dialog.getChoice();
proj = Dialog.getRadioButton();

if (channels == 2) {
	order = newArray(c1, c2);
}

if (channels == 3) {
	order = newArray(c1, c2, c3);
}

if (channels == 4) {
	order = newArray(c1, c2, c3, c4);
}


suffix = newArray("", "_Phalloidin", "_Zasp", "_Hoe", "_Brp", "_Lamin", "_pMad", "_HRP", "_Dlg", "_Fibrillarin", "H3K9");

// =========================================================================================================================
// * Identify the directory to access files * 

dir = getDirectory("Choose input Directory"); // Select the directory
list = getFileList(dir); // List of all of the files in the directory

analysis = dir + "/analysis-files/";
File.makeDirectory(analysis);

// =========================================================================================================================
// * Step 1: File type converstion * 

if (type == "Hyperstack per position") {

	step2();
	
	}

// ---------------------------------------------

if (type == "TIFF per position") {

	setBatchMode(true);
	
	reduceTIFF(dir);

	step2();
	
	}

// ---------------------------------------------

if (type == "ND2 per position") {

	setBatchMode(true); 

	R2ND2(dir);

	step2();
	
	}

// ---------------------------------------------

if (type == "CZI") {

	setBatchMode(true); 

	R2ND2(dir);

	step2();
	
	}

// ---------------------------------------------

if (type == "LIF") {

	setBatchMode(true); 
	
	R2ND2(dir);

	step2();
	
	}

// ---------------------------------------------	

if (type == "Single Z slice per position") { 

	setBatchMode(true);
	
	singleZ(dir);

	step2();
	
	}

// ---------------------------------------------

if (type == "Individual channels per position") {

	setBatchMode(true);

	Dialog.create("Image Parameters");
		Dialog.addNumber("Slices", 1);
		Dialog.show();
		
		slices = Dialog.getNumber();

	if (channels == 3) {
	
		threechannels(dir);
	
		}
		
	if (channels == 4) {
	
		fourchannels(dir);
	
		}

	step2();
	
	}

// ---------------------------------------------

if (type == "Multiposition tiff") {
	
	setBatchMode(true); 
	
	DontKeepItMultiPG(dir);

	step2();
	
	}

// =========================================================================================================================
// * Functions that allow for converting the images *

function binning(path, dir) {
		
		setBatchMode(false);
		
		indexx = indexOf(path, ".t");
	
	    name = substring(path, 0, indexx);
		
		open(name + "_Hoe.tif");

		run("32-bit");

		image = getTitle();
			
		masked = threshold(image, "Define threshold");

		selectImage(masked);

		saveAs("Tiff", name + "_Nuc-bin");

		close();
		

		//if(endsWith(path, "_Lamin")){

			//masked = threshold(image, "Define threshold");

			//selectImage(masked);

			//saveAs("Tiff", dir + name + "_Nuc-bin");
			
			//}

//Skip this step if any of the channels = Lamin 
		
		//if (endsWith(path, "e.tif")) {

			//print("Hoechst");
			
			//masked = threshold(image, "Define threshold");

			//selectImage(masked);

			//saveAs("Tiff", dir + name + "_Nuc-bin");
			
			//}

		//Dialog.create("Update Nuc-bin");
		//	Dialog.addChoice("Remove unwanted nuclei now?", answer, "No");
			//Dialog.show();

		//ans = Dialog.getChoice();

		//if (ans == "Yes") {

			//setTool("brush");
					
			//run("Paintbrush Tool Options...", "brush=60");

			//open(dir + name + "_Nuc-bin.tif");

			//selectWindow(dir + name + "_Nuc-bin.tif");

			//waitForUser("mask", "Adjust windows so that you can see both the mask and the nuclear stack.\n Use the paintbrush to remove unwanted nuclei.\n Click OK to continue");
		
			//close();
				
		//	}

		//if (c3 == "Fibrillarin") {

			//open(dir + name + "_Fibrillarin.tif");

			//change = getTitle();

			//masked = threshold(change, "Define threshold");

			//selectImage(masked);

			//saveAs("Tiff", dir + name + "_Fib-bin");

			//Dialog.create("Update Fib-bin");
			//Dialog.addChoice("Remove unwanted nucleoli now?", answer, "No");
			//Dialog.show();

			//ans = Dialog.getChoice();
	
			//if (ans == "Yes") {
	
				//setTool("brush");
						
				//run("Paintbrush Tool Options...", "brush=60");
	
				//open(dir + name + "_Fib-bin.tif");
	
				//selectWindow(name + "_Fib-bin.tif");
	
				//waitForUser("mask", "Use the paintbrush to remove unwanted nucleoli.\n Click OK to continue");
			
				//close();
					
				//}
			//}

		//if (c4 == "Fibrillarin") {

			//open(dir + name + "_Fibrillarin.tif");

			//change = getTitle();

			//masked = threshold(change, "Define threshold");

			//selectImage(masked);


			//saveAs("Tiff", dir + name + "_Fib-bin");

			//Dialog.create("Update Fib-bin");
			//Dialog.addChoice("Remove unwanted nucleoli now?", answer, "No");
			//Dialog.show();

			//ans = Dialog.getChoice();
	
			//if (ans == "Yes") {
	
				//setTool("brush");
						
				//run("Paintbrush Tool Options...", "brush=60");
	
				//open(dir + name + "_Fib-bin.tif");
	
				//selectWindow(name + "_Fib-bin.tif");
	
				//waitForUser("mask", "Use the paintbrush to remove unwanted nucleoli.\n Click OK to continue");
			
				//close();
					
				//}
			//}
	
	}

// ---------------------------------------------

function bioEXP(dir, extension) {

// Based on Macro https://gist.github.com/lacan/16e12482b52f539795e49cb2122060cc

	setBatchMode(true);
	n=0;
	
	run("Bio-Formats Macro Extensions");
	for(f = 0; f < list.length; f++) {
		
		if(endsWith(list[f], "." + extension)) {
			
			id = dir+list[f];
			Ext.setId(id);
			Ext.getSeriesCount(seriesCount);
			n+=seriesCount;
			
			for (i = 0; i < seriesCount; i++) {
				
				run("Bio-Formats Importer", "open=["+id+"] color_mode=Default view=Hyperstack stack_order=XYCZT series_"+(i + 1));
				
				fullName	= getTitle();
				fileName 	= substring(fullName, lastIndexOf(fullName, " - ")+3, lengthOf(fullName));
				dirName 	= substring(fileName, 0,lengthOf(fileName));
				File.makeDirectory(analysis+File.separator+dirName+File.separator);

				selectWindow(fullName);
				
				saveAs("Tiff", analysis+File.separator+dirName+File.separator + fileName + ".tif");
				
				getDimensions(x,y,c,z,t);

				run("Close All");
				
				}
			}
	
		Ext.close();
	
	}
}

// ---------------------------------------------

function DontKeepItMultiPG (dir) {

	setBatchMode(true);
	
	for (i=0; i < list.length; i++) { // go through all the files in the directory

		filename = dir + list[i];
		
		if (endsWith(filename, "tif")) { 
			
			open(filename); // open the multipoint tiff

			Dialog.create("DontKeepItMultiPG"); // designate the parameters of the multipoint tiff
				Dialog.addNumber("How many positions are in this image?", 1);
				Dialog.addChoice("What type of projection should be used?", projection);
				Dialog.show();
		
			positions = Dialog.getNumber();
			proj = Dialog.getChoice();

			slices = nSlices/(channels*positions);
	
			run("Stack to Hyperstack...", "order=xyczt(default) channels=channels slices=slices frames=positions display=proj");
			// Converts multipoint tiff into a hyperstack with 3 dimensions: channels, slices and frames
	
		    name = File.getName(filename);
	
		    indexx = indexOf(name, ".t");
	
		    experiment = substring(name, 0, indexx-1);
	
			saveAs("Tiff", analysis + experiment + "_hyperstack"); // save hyperstack as tiff
	
			selectWindow(analysis + experiment + "_hyperstack.tif"); 
	
			for (a = 1; a <= positions; a++) { // for the number of positions told in the dialog box, split into individual tiffs
				
				Stack.setPosition(1, 1, a); // set the hyperstack to that position
			
				run("Reduce Dimensionality...", "channels slices keep"); 
				// reduce the dimensions to make a hyperstack that only has the channels and slices at that position

				if (a < 10) {
					saveAs("Tiff", analysis + experiment + "_0" + a + "/" + experiment + "_0" + a);
					}
				
				else {
					saveAs("Tiff", analysis + experiment + "_" + a + "/" + experiment + "_" + a); // save individual position tiff
					}
	
				close(); // close file
			
				}
			}
		}	
	}

// ---------------------------------------------

function flatstack(file, dir) {
		
		name = File.getName(file); // get filename 

		if (startsWith(file, "stack_")) {
		
			index = indexOf(nombre, "k_"); // find the position of the end of "stack_"
			
			expt = substring(nombre, index+2); // grab the substring of the filename that does not contain "stack_"
			
			run("Z Project...", "start=1 projection=["+proj+"]"); // create a sum slices projection
			
			saveAs("Tiff", dir + "flatstack_" + expt); // save as tiff
		
			run("Close All");
		} 
	}

// ---------------------------------------------

function folderCreate(dir) { // create a folder for each hemisegment
      
      list = getFileList(dir);
      
      for (i = 0; i < list.length; i++) {

		if (endsWith(list[i], ".tif")) {
		
			name = File.getName(dir + list[i]);
						
			indexx = indexOf(name, "_x");
						
			position = substring(name, indexx+3, indexx+5);

			indiv = analysis + "/Hemisegment-" + position + "/";

			File.makeDirectory(indiv);
			
			}

		if (endsWith(list[i], ".nd2")) {
		
			name = File.getName(dir + list[i]);
						
			indexx = indexOf(name, "_x");
						
			position = substring(name, indexx+3, indexx+5);
						
			experiment = substring(name, 0, indexx);

			indiv = analysis + "/Hemisegment-" + position + "/";

			File.makeDirectory(indiv);
			
			}
		else {continue;}
		
		}
 	 }

// ---------------------------------------------

function fourchannels(dir) { // Takes a multichannel TIFF and creates one TIFF stack with four channels per position

	setBatchMode(true);
	
	for (i = 0; i < list.length; i += 4) {
			
		    open(list[i]);
		    ch1=getTitle();
		
		    open(list[i+1]);  
		    ch2=getTitle();
		
		    open(list[i+2]);
		    ch3=getTitle();
		
		    open(list[i+3]);
		    ch4=getTitle();
		
		    run("Concatenate...", "all_open title=XY_concat open");
	
			selectWindow("XY_concat");

			slices = nSlices/channels;
	
		    run("Stack to Hyperstack...", "order=xytzc channels=channels slices=slices frames=1 display=["+proj+"]");
	
		    filename = dir + list[i]; 
	
		    name = File.getName(filename);
		    
		    indexx = indexOf(name, ".t");
		    
		    position = substring(name, indexx-2, indexx);
	
		    experiment = substring(name, 0, indexx-5); //figure out what actually is the starting index
	
			saveAs("Tiff", analysis + experiment + "_" + position + "/" + experiment + "_" + position);
	
			close();
		
		}
	}

// ---------------------------------------------

function interactiveROIselect(image,caption){
	
	selectImage(image);
	
	run("Select None");

	waitForUser("Crop", "Use the rectangle to set ROI, then click OK.");
	
	do	{
		setTool("rectangle");
		
		type = selectionType();
		
	} while (type ==-1)

	run("Crop");
	
	cropped = getImageID();
	
	run("Select None");

	return (cropped);
}

// ---------------------------------------------

function limitZ(path) {
					
		open(path);

		waitForUser("limitZ", "Scroll through stack, identify slices to keep, and then click OK.");

		run("Duplicate...");
		
		saveAs("Tiff", path);
		
		run("Close All");
 	 
 	 }

// ---------------------------------------------

function nucleART(path, dir) { // create the two channel images required for Bob and NMJ Morphometrics
				
		open(path);

		name = getTitle();
	
	    name = substring(name, 0, indexOf(name, ".t"));

		run("Z Project...", "start=1 projection=["+proj+"]");
	
		saveAs("Tiff", dir + name + "_Projection");

		selectWindow(name + "_Projection.tif");

		title = getTitle();

		run("Split Channels");
			
		one = "C1-" + title;
			
		two = "C2-" + title;

		if (channels == 2) {
			ctitle = newArray(one, two);
		}
		

		if (channels  == 3) { 
				
			three = "C3-" + title;
			ctitle = newArray(one, two, three);
				
			}	

		if (channels == 4) {
				
			three = "C3-" + title;
			four = "C4-" + title;
				
			ctitle = newArray(one, two, three, four);
				
			}

		for (i = 0; i < order.length; i++) {

			for (j = 0; j < chan.length; j++) {

				if (order[i] == chan[j]) {

					selectWindow(ctitle[i]);
					
					saveAs("Tiff", dir + name + suffix[j]);

					close();
						
					}
				}
			}
			
			
		}	
		
// ---------------------------------------------

function neuroMJ(path) { // create the two channel images required for Bob and NMJ Morphometrics
		
		if (c3 == "HRP") {

			open(path);
			
			indexx = indexOf(path, ".t");
	
		    name = substring(path, 0, indexx);

			title = getTitle();
						
			run("Split Channels");
			
			one = "C1-" + title; // hoechst
			
			two = "C2-" + title; // zasp
			
			three = "C3-" + title; // HRP/Dlg

			selectWindow(one);
			
			close();

			selectWindow(two);
			
			close();
			
			selectWindow(three);

			title = getTitle();

			title = substring(title, 3);
						
			saveAs("Tiff", dir + "stack_" + title);

			stacked = getTitle();

			flatstack(stacked, dir);
			
			}
		
		if (c3 == "Dlg") {

			open(path);
			
			indexx = indexOf(path, ".t");
	
		    name = substring(path, 0, indexx);

			title = getTitle();
						
			run("Split Channels");
			
			one = "C1-" + title; // hoechst
			
			two = "C2-" + title; // zasp
			
			three = "C3-" + title; // HRP/Dlg

			selectWindow(one);
			
			close();

			selectWindow(two);
			
			close();
			
			selectWindow(three);

			title = getTitle();

			title = substring(title, 3);
						
			saveAs("Tiff", dir + "stack_" + title);

			stacked = getTitle();

			flatstack(stacked, dir);
			
			}
		
		if (c3 == "Brp" && c4 == "HRP") {

			open(path);

			indexx = indexOf(path, ".t");
	
		    name = substring(path, 0, indexx);

			title = getTitle();
						
			run("Split Channels");
			
			one = "C1-" + title; 
			
			two = "C2-" + title; 
			
			three = "C3-" + title; 

			four = "C4-" + title; 

			selectWindow(one);
			
			close();

			selectWindow(two);
			
			close();
	
			run("Merge Channels...", "c1=["+three+"] c2=["+four+"]");
						
			saveAs("Tiff", dir + "stack_" + name);
	
			stacked = getTitle();
	
			flatstack(stacked, dir);
				
			}
		

		if (c3 == "pMad" && c4 == "HRP") {

			open(path);

			indexx = indexOf(path, ".t");
	
		    name = substring(path, 0, indexx);

			title = getTitle();
						
			run("Split Channels");
			
			one = "C1-" + title; 
			
			two = "C2-" + title; 
			
			three = "C3-" + title; 

			four = "C4-" + title; 

			selectWindow(one);
			
			close();

			selectWindow(two);
			
			close();
	
			run("Merge Channels...", "c1=["+three+"] c2=["+four+"]");
						
			saveAs("Tiff", dir + "stack_" + name);
	
			stacked = getTitle();
	
			flatstack(stacked, dir);
			
			}

		if (c3 == "pMad" && c4 == "Dlg") {

			open(path);

			indexx = indexOf(path, ".t");
	
		    name = substring(path, 0, indexx);

			title = getTitle();
						
			run("Split Channels");
			
			one = "C1-" + title; 
			
			two = "C2-" + title; 
			
			three = "C3-" + title; 

			four = "C4-" + title; 

			selectWindow(one);
			
			close();

			selectWindow(two);
			
			close();
	
			run("Merge Channels...", "c1=["+three+"] c2=["+four+"]");
						
			saveAs("Tiff", dir + "stack_" + name);
	
			stacked = getTitle();
	
			flatstack(stacked, dir);
			
			}

		if (c3 == "Dlg" && c4 == "pMad") {

			open(path);

			indexx = indexOf(path, ".t");
	
		    name = substring(path, 0, indexx);

			title = getTitle();
						
			run("Split Channels");
			
			one = "C1-" + title; 
			
			two = "C2-" + title; 
			
			three = "C3-" + title; 

			four = "C4-" + title; 

			selectWindow(one);
			
			close();

			selectWindow(two);
			
			close();
	
			run("Merge Channels...", "c1=["+three+"] c2=["+four+"]");
						
			saveAs("Tiff", dir + "stack_" + name);
	
			stacked = getTitle();
	
			flatstack(stacked, dir);
			
			}

		run("Close All");
		
	}


// ---------------------------------------------

function rotate(path) {
				
	open(path);

	title = getTitle();

	selectImage(title);
	
	run("Select None");

	waitForUser("Rotate", "Visualize the cell, then click OK.\nOn next window, check preview to view rotated image.");

	run("Rotate... ");
		
	saveAs("Tiff", path);
	
	close();
	
	}

// ---------------------------------------------

function ohCrop(path) {
				
	open(path);

	title = getTitle();
		
	cropFile = interactiveROIselect(title, "Rotate and crop image");
		
	selectImage(cropFile);
	
	saveAs("Tiff", path);
	
	close();
	
	}

// ---------------------------------------------

function processFiles(dir, funct) {
      
      list = getFileList(dir);
      
      for (i = 0; i < list.length; i++) {
          
          if (endsWith(list[i], "/"))
              processFiles(""+dir+list[i], funct);
         
          if (endsWith(list[i], ".tif")) {
             	if (i > 0) {continue;}
             	
             	path = dir+list[i];

             	if(funct == "rotate"){
					rotate(path);}

				if(funct == "ohCrop"){
					ohCrop(path);}

				if(funct == "limitZ"){
					limitZ(path);}

				if(funct == "nucleART"){
					setBatchMode(true);
					nucleART(path, dir);}

				if(funct == "neuroMJ"){
					neuroMJ(path, dir);}

				if(funct == "ThreeNMJ"){
					ThreeNMJ(path, dir);}

				if(funct == "flatstack"){
					flatstack(path, dir);
				}

				if(funct == "binning") {
					binning(path, dir);
				}

          	}
      	}
 	 }

// ---------------------------------------------

function R2ND2(dir) {

	for (i = 0; i < list.length; i++) {
	
			if (endsWith(list[i], ".nd2")) {
			
				run("Bio-Formats Importer", "open=["+ dir + list[i] +"] autoscale color_mode=Colorized view=Hyperstack stack_order=XYCZT");
			
				indexx = indexOf(list[i], "_x");
	
				experiment = substring(list[i], 0, indexx);
									
				position = substring(list[i], indexx+3, indexx+5);
				
				saveAs("Tiff", analysis + experiment + "_" + position + "/" + experiment + "_" + position);
				
				close();
	
				}

			if (endsWith(list[i], ".czi")) {
			
				bioEXP(dir, "czi");
				
				run("Bio-Formats Importer", "open=["+ dir + list[i] +"] autoscale color_mode=Colorized view=Hyperstack stack_order=XYCZT");
			
				indexx = indexOf(list[i], "_x");
	
				experiment = substring(list[i], 0, indexx);
									
				position = substring(list[i], indexx+3, indexx+5);
				
				saveAs("Tiff", analysis + experiment + "_" + position + "/" + experiment + "_" + position);
				
				close();
	
				}

			if (endsWith(list[i], ".lif")) {
			
				bioEXP(dir, "lif");
				
				}	
			}	
		}
	
// ---------------------------------------------

function reduceTIFF (dir) {

	Dialog.create("reduceTIFF"); // designate the parameters of the multipoint tiff
		Dialog.addNumber("Channels", 1);
		Dialog.addNumber("Slices", 1); 
		Dialog.show();
		
	channels = Dialog.getNumber();
	slices = Dialog.getNumber();

	setBatchMode(true);

	for (i = 0; i < list.length; i++) {
	
		open(list[i]);
		
		run("Stack to Hyperstack...", "order=xyczt(default) channels=channels slices=slices frames=1 display=Grayscale");
	
		indexx = indexOf(list[i], "_x");
							
		position = substring(list[i], indexx+3, indexx+5);
		
		saveAs("Tiff", analysis + experiment + "_" + position + "/" + experiment + "_" + position);
		
		close();
					
		}
	}

// ---------------------------------------------

function singleZ(dir) {

	Dialog.create("singleZ");
		Dialog.addMessage("How many z slices per position?");
		Dialog.addNumber("slices", 1);
		Dialog.show();
	
	slices = Dialog.getNumber(); 

	setBatchMode(true);

	for (i=0; i < list.length; i+=slices) { // for all files in directory, next run of the loop will start at the next position because i+=slices
	
		for (j=0; j < slices; j++) { // open all files of number of slices
			
			open(list[i+j]); 
				
			}
	
		run("Concatenate...", "all_open title=XY_multipage open"); // turn into one stack 
	
		run("Stack to Hyperstack...", "order=xytzc channels=4 slices=slices frames=1 display=Grayscale"); // create hyperstack to be able to switch channels and z stacks because of how nikon saves their images
	
		name = File.getName(dir + list[i]);
				
		indexx = indexOf(name, "xy");
				
		position = substring(name, indexx+2, indexx+4);
			
		saveAs("Tiff", analysis + experiment + "_" + position + "/" + experiment + "_" + position); // save file
			
		close();
			
		}
	}

// ---------------------------------------------

function step2() {
	
	Dialog.create("Pre-processing");	
		Dialog.addMessage("Note: images need to be completely horizontal or vertical for proper Bob analysis");
		Dialog.addRadioButtonGroup("Do you need to rotate any of the stacks?", answer, 1, 2, "No");
		Dialog.addRadioButtonGroup("Do you need to crop any of the stacks?", answer, 1, 2, "No");
		Dialog.addRadioButtonGroup("Do you need to remove z slices from any of the stacks?", answer, 1, 2, "No");
		Dialog.show();
	
	rot = Dialog.getRadioButton();
	crop = Dialog.getRadioButton();
	limit = Dialog.getRadioButton();

	if (rot == "Yes") {

		processFiles(analysis, "rotate");
	
		}

	if (crop == "Yes") {
		
		processFiles(analysis, "ohCrop");
		
		}

	if (limit == "Yes") {

		processFiles(analysis, "limitZ");

		step3();
		
		}

	if (limit == "No") {

		step3();
		
		}
	}

// ---------------------------------------------

function step3() {

	Dialog.create("Channel Images");
		Dialog.addMessage("This step creates images for each channel.");	
		Dialog.addRadioButtonGroup("Would you like to create a nuclear bin?", answer, 1, 2, "No");
		//Dialog.addRadioButtonGroup("Would you like to create a fibrillarin bin?", answer, 1, 2, "No");
		Dialog.show();
	
	bin = Dialog.getRadioButton();
	//fib = Dialog.getRadioButton();
	
	processFiles(analysis, "nucleART");

	if (bin == "Yes") {
		
		processFiles(analysis, "binning");
		
		}

	//if (fib == "Yes") {
		
		//processFiles(analysis, "binning");
		
		//}
	
	step4();

	}

// ---------------------------------------------

function step4() {
	
	Dialog.create("NMJ Images");
		Dialog.addRadioButtonGroup("Would you like to create composite files for NMJ analysis?", answer, 1, 2, "No");
		Dialog.show();

	neuron = Dialog.getRadioButton();

	if (neuron == "No") {

		waitForUser("mulTIFFly analysis", "File generation is complete!");
		
		}

	if (neuron == "Yes") {

		processFiles(analysis, "neuroMJ");
	
		waitForUser("mulTIFFly analysis", "File generation is complete!");
	
		}
	}


// ---------------------------------------------

function threechannels(dir) {
	
	setBatchMode(true);
	
	for (i = 0; i < list.length; i += 3) {
		
		open(list[i]);
		ch1=getTitle();
		
		open(list[i+1]);  
		ch2=getTitle();
		
		open(list[i+2]);
		ch3=getTitle();
		
		run("Concatenate...", "all_open title=XY_concat open");
	
		selectWindow("XY_concat");
	
		run("Stack to Hyperstack...", "order=xytzc channels=channels slices=slices frames=1 display="[+proj+"]");

		filename = dir + list[i]; 
	
		name = File.getName(filename);

		indexx = indexOf(name, "xy");

		position = substring(name, indexx+2, indexx+4);
	
		experiment = substring(name, 0, indexx-1);
	
		saveAs("Tiff", analysis + experiment + "_" + position + "/" + experiment + "_" + position);
	
		close();
	}


// ---------------------------------------------

function threshold(image,caption)	{
	
	selectImage(image);

	run("8-bit");
	
	setAutoThreshold("Default dark");
	
	run("Threshold...");

	setOption("BlackBackground", true);
	
	waitForUser(caption, "Adjust threshold method.\n Select: dark background, click auto, click apply.\n Create mask, then click OK to continue.");
	
	run("Convert to Mask");

	run("Close-");
	
	run("Watershed");
	
	mask = getImageID();
	
	run("Select None");

	return (mask);

	}


// =========================================================================================================================

 // * END OF MACRO *