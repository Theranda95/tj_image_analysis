//  MACRO - shortest distance to line
//  http://microscopynotes.com/imagej/shortest_distance_to_line/index.html

//  If data published using the macro, please acknowledge the 
//  OFFICE OF COLLABORATIVE SCIENCE (OCS) MICROSCOPY CORE at NYU Langone Medical Center
//  v100 by Michael Cammer 20140825 as a demonstration for Leonor Remedio.
//  v101,102 modified for Willy Ramos to measure cell distances from a closed structure.
//  v103 20141028_1100 adds text output to the same directory/folder that the image is from. 
//  v104 20141030_1510 gives the option of closed polygon, line, or point as the reference shape.  No error checking for multiple selections.


//  This macro requires a ROI Manager window populated with:
//  ROIs that represent the structures to have their distances measured to a maset structure.
//  The minimum length from each point is calculated to the line.
//  This shortest path is drawn for each.

//  The first ROI in the Manager must be the reference structure.  If it is not:
//  1.  draw the reference structure
//  2.  add it to the ROI manager so now it is the last one
//  3.  use the macro "Make the last ROI the first"


//  If there is a ROI Manager full of points but the big area to relate them to hasn't been
//  entered yet:

//  macro "Make the last ROI the first" {
//  requires("1.49k");
//  roiManager("select", roiManager("count")-1);
//  roiManager("Rename", "0");
//  roiManager("Deselect");
//  roiManager("Sort");
//  }

//  If ROIs are already in the right order start here.

macro "Measure distance to line [q]" {
  requires("1.49k");
  path = getDirectory("image");  // used for outputting the results
  title = getTitle();                          // used for outputting the results
  title = replace(title, ".tif", "");  title = replace(title, ".lsm", "");  title = replace(title, ".czi", "");   title = replace(title, ".jpg", "");  
  title = replace(title, ".TIF", "");  title = replace(title, ".LSM", "");  title = replace(title, ".CZI", ""); title = replace(title, ".JPG", "");  
  run("Remove Overlay");  // cleans up any previous overlays -- may be deleted or commented out
  getPixelSize(unit, pixelWidth, pixelHeight);
  run("Set Scale...", "distance=1 known=1 unit=pixel");
  roiManager("select", 0);
  if (selectionType() < 5) closedShape = true; else closedShape = false;
  run("Interpolate", "interval=2");  //  half as fast and arguably more precise, change to 1
  getSelectionCoordinates(x, y);
  Roi.setStrokeColor("#0080ff");
  run("Add Selection...");
  run("Set Measurements...", "  centroid redirect=None decimal=1");
  output = File.open(path + title + "_results.txt");
  print("selection#  \t  units \t distance \t units");
  print(output, "selection#  \t  units \t distance \t units");
  for (selection=1;  selection<roiManager("count");  selection++){
      roiManager("select", selection);
      run("Measure");
      xc = getResult("X", nResults()-1);          // get centroid
      yc = getResult("Y", nResults()-1);
      min = 9999999999999;
      for (line=0; line<x.length; line++) {
        dx = xc - x[line];
        dy = yc - y[line];
        d = sqrt( (dx*dx) + (dy*dy));
        if (d < min) { min = d;  lx = x[line];  ly = y[line]; }
      }  // for each point on the line
      // make negative if inside the big shape.
     // select the big shape

     color1 = "#00ff";   
     if (closedShape) {
       roiManager("select", 0);
       inside = Roi.contains(xc, yc);  //Returns "1" if the point x,y is inside the current selection or "0" if it is not. 
       if (inside > 0) {
         min = min * (-1);
         color1 = "#ff00";
       } // if > 0
     }  // if closedShape
     print((selection+1) + " \t " + min + " \t pixels\t "+ (min*pixelWidth) + " \t " + unit);
     print(output, (selection+1) + " \t " + min + " \t pixels\t "+ (min*pixelWidth) + " \t " + unit);
     makeLine(xc, yc, lx, ly);
     Roi.setStrokeColor(color1 + "ff");
     run("Add Selection...");

  }  // for each selection

  run("Select None");
  run("Set Scale...", "distance=1 known="+pixelWidth+"  unit="+unit);  // restore scale to image; assumes square pixels
  run("Clear Results");
  File.close(output);
  selectWindow("Log");
}