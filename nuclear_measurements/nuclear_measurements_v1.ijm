open("/Users/therandajashari/Desktop/test/Input/23.02.16_D7_KO2_ttn_AchR_Phall_60x_007.nd2");
selectWindow("23.02.16_D7_KO2_ttn_AchR_Phall_60x_007.nd2");
run("Split Channels");
close();
close();
close();
selectWindow("C1-23.02.16_D7_KO2_ttn_AchR_Phall_60x_007.nd2");
run("Z Project...", "projection=[Max Intensity]");
selectWindow("C1-23.02.16_D7_KO2_ttn_AchR_Phall_60x_007.nd2");
close();
run("Z Project...", "projection=[Max Intensity]");
saveAs("Tiff", "/Users/therandajashari/Desktop/test/Output/MAX_23.02.16_D7_KO2_Hoe_007.tif");
selectWindow("23.02.16_D7_KO2_ttn_AchR_Phall_60x_007.nd2 - C=0");
selectWindow("MAX_23.02.16_D7_KO2_Hoe_007.tif");
setAutoThreshold("Default dark no-reset");
//run("Threshold...");
setAutoThreshold("Default dark no-reset");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Fill Holes");
run("Watershed");
//setThreshold(255, 255);
saveAs("Tiff", "/Users/therandajashari/Desktop/test/Output/MAX_23.02.16_D7_KO2_MaskHoe_007.tif");

run("Analyze Particles...", "size=45-Infinity display exclude summarize add");
saveAs("Results", "/Users/therandajashari/Desktop/test/Output/MAX_23.02.16_D7_KO2_Hoe_007_NuclearSummary.csv");
saveAs("Results", "/Users/therandajashari/Desktop/test/Output/MAX_23.02.16_D7_KO2_Hoe_007_NuclearResults.csv");
close();
run("Close");
run("Close");
