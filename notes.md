image -> "image_1_k02_d10.nd2"

- Grab the name of the image without the .nd2
    -  image_1_k02_d10
- Add to the name of image the ".roi"
    - "image_1_k02_d10" + ".roi"  = "image_1_k02_d10.roi"


// * Identify the directory to access files * 
dir_images = getDirectory("Choose input Directory"); // Select the directory
dir_roi = getDirectory("Choose rio Directory"); // Select the directory
//print(dir);


roiManager("Open", "/Users/therandajashari/Desktop/test/Test_roi/D7_KO2_0072pt.roi");
roiManager("Open", dir_rio + "/D7_KO2_0072pt.roi");


// rio_image = "/Users/therandajashari/Desktop/test/Test_roi/D7_KO2_0072pt.roi"
// rio_image = dir_rio + "D7_KO2_0072pt.roi"
rio_image = dir_rio + "image_name" + ".roi"