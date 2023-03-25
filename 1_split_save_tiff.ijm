open("/Users/therandajashari/Desktop/testMultiFFLY/MulTIFFlyInput/23.02.16_D7_KO2_ttn_AchR_Phall_60x_007.nd2");
selectWindow("23.02.16_D7_KO2_ttn_AchR_Phall_60x_007.nd2");
run("Split Channels");
run("Z Project...", "projection=[Max Intensity]");
saveAs("Tiff", "/Users/therandajashari/Desktop/testMultiFFLY/MulTIFFlyoutput/MAX_23.02.16_D7_KO2_Hoe_007.tif");