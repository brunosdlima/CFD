/* 
This script calculates the average of the film profile in a chosen folder.
Make sure to change the values of fps and pixel size in the section Input variables. Also change the tunning variables if necessary.
Make sure that there are in the chosen folder the following files: "zbackground.bmp" and "zstandard.bmp". This files are used to calculate the reflection of the plate.
Considering the alphabetical order your sequence of images should come before "zbackground.bmp" and "zstandard.bmp".
It must not contain any other files. After printing results as txt files you need to remove it from the folder in order to run the script again.
*/
//Variables for printing and saving files
printingWindows=true;				//Print results to new windows on Fiji
if (printingWindows) {
	closeResultsFilm=true;			//Close results of film windows (only make it true if printingWindows is true)
	closeTestResults=true;			//Close results window for testing (only make it true if printingWindows is true)
	printingTxt=true;				//Print results to txt files (only make it true if printingWindows is true)
}
closePictures=true;  				//Close working pictures
closeAveragePictures=true;			//Close average images
fillEmpty=false;					//Fill empty spaces on images (This process is time consuming)
printAverageImage=true;				//Print the average image
printAverageImage2=true;			//Print the average image in the center of image
set_batch=true;						//Setting batch makes the script run faster by not opening the images
//End of setting variables for printing
setBatchMode(false);
if (set_batch) {
	setBatchMode(true);
}
//Cleaning outputs
run("Clear Results");
print("\\Clear");
if (isOpen("Log")) { 
	selectWindow("Log"); 
	run("Close"); 
} 
if (isOpen("Results")) { 																		
	selectWindow("Results"); 
	run("Close"); 
}
//Creating windows on Fiji
if(printingWindows){
	title1 = "Results_profile"; 
	title2 = "["+title1+"]"; 
	f1=title2; 
	run("New... ", "name="+title2+" type=Table"); 
	title5 = "TESTS"; 
	title6 = "["+title5+"]"; 
	f3=title6; 
	run("New... ", "name="+title6+" type=Table");
}
//Input variables (change for your case)
fps=10000; 						//frames per second [1/s]
pixelSize=29/734; 				//size of each pixel [mm/pixel]
//Fine tune parameters
dropletFiltered=0.3; 			//Variable used to filter the splashed droplets
search_pool=250;				//Variable used to look for maximum width of the pool
define_pool=1.6;				//Variable used to define pool width in comparison to upstream flow
average_cut=9;					//Variable used to define the top of the pool
subtract_background=40;			//Variable used to set background rolling
set_threeshold=30;				//Variable used to set threeshold
// Combining zbackground and image then making binary and fililing holes
dir1 = getDirectory("Choose Source Directory ");
list1 = getFileList(dir1);
if (File.exists(dir1 + "zbackground.bmp") && File.exists(dir1 + "zstandard.bmp") && !File.exists(dir1 + "average.bmp")) { //Check if zbackground and zstandard are on the working folder and if there is the average file
//Initializing parameters
setOption("ExpandableArrays", true);
Width_mean= newArray();
DistanceEdge_mean= newArray();
y_mean= newArray();
lenghtlist=list1.length;
open(dir1 + "zbackground.bmp");
width = getWidth;
height = getHeight;
if (isOpen("zbackground.bmp")) { 
      selectWindow("zbackground.bmp"); 
      run("Close"); 
}
for (y_Pos = 0; y_Pos < height+200; y_Pos++) {
	DistanceEdge_mean[y_Pos]=0;
	Width_mean[y_Pos]=0;
}
//Finding maximum width location of the pool
open(dir1 + "zbackground.bmp");
open(dir1 + "zstandard.bmp");
imageCalculator("Difference", "zstandard.bmp","zbackground.bmp");
if (isOpen("zbackground.bmp")) { 
      selectWindow("zbackground.bmp"); 
      run("Close"); 
}
if (isOpen("zstandard.bmp")) { 
      selectWindow("zstandard.bmp");
}
run("Subtract Background...", "rolling=subtract_background sliding");
setOption("BlackBackground", true);
setAutoThreshold("Default dark");
run("Threshold...");
setThreshold(set_threeshold, 255);
run("Convert to Mask");
if (isOpen("zstandard.bmp")) { 
	selectWindow("zstandard.bmp"); 
}
run("Make Binary");
run("Fill Holes");
setTool("rectangle");
makeRectangle(0, 0, width, height);
run("Set Measurements...", "area centroid bounding redirect=None decimal=3");
run("Analyze Particles...", "  circularity=dropletFiltered-1.00 show=Masks clear");
imageCalculator("Difference", "zstandard.bmp","Mask of "+"zstandard.bmp");
if (isOpen("Mask of "+"zstandard.bmp")) { 
	selectWindow("Mask of "+"zstandard.bmp"); 
	run("Close");
}
if (isOpen("zstandard.bmp")) { 
	selectWindow("zstandard.bmp"); 
}
width = getWidth;
height = getHeight;
Maximum_local_width=0;
count=0;
for (y_Pos = 0; y_Pos < height; y_Pos++) {
	x_low=999999;
	x_high=0;
	makeLine(0, y_Pos, width, y_Pos);
	run("Clear Results");
	profile = getProfile();
	for (j_edge=1; j_edge<profile.length; j_edge++){
		x=j_edge;
		point_value=profile[j_edge];
		if (point_value>125) {//Detect white
			if (x>x_high) {//Lowest x
				x_high=x;
			}
			if (x<x_low) {
				x_low=x;
			}
		}
	}
	if (x_low>999000) {
		x_low=0;
	}
	Local_width=(x_high-x_low);
	if (Local_width>=Maximum_local_width) {
		Maximum_local_width=Local_width;
		y_maximum_pool=y_Pos;
		x_average_maximum_pool=(x_high+x_low)/2;
	}
	count++;
	if (Local_width<average_cut) {
		Local_width=average_cut;
	}
	if (Maximum_local_width>define_pool*Local_width && Maximum_local_width>average_cut) {	
		y_Pos=height;
	}
}
if (isOpen("zstandard.bmp")) { 
      selectWindow("zstandard.bmp"); 
      run("Close"); 
}
//Working with the list of images
for (i = 0; i < lenghtlist-2; i++) {  //Working on all the images
	open(dir1+list1[i]);
	if(printingWindows){
		print(f3,list1[i]);			//print current picture on TESTS window
	}
	// Combining zbackground and image then making binary and fililing holes
	open(dir1 + "zbackground.bmp");
	imageCalculator("Difference", list1[i],"zbackground.bmp");
	if (isOpen("zbackground.bmp")) { 
		selectWindow("zbackground.bmp"); 
		run("Close"); 
	}
	if (isOpen(list1[i])) { 
		selectWindow(list1[i]);
	} 
	run("Subtract Background...", "rolling=subtract_background sliding");
	setOption("BlackBackground", true);
	setAutoThreshold("Default dark");
	run("Threshold...");
	setThreshold(set_threeshold, 255);
	run("Convert to Mask");
	if (isOpen(list1[i])) { 
		selectWindow(list1[i]); 
	}
	run("Make Binary");
	run("Fill Holes");
	setTool("rectangle");
	makeRectangle(0, 0, width, height);
	run("Set Measurements...", "area centroid bounding redirect=None decimal=3");
	run("Analyze Particles...", "  circularity=dropletFiltered-1.00 show=Masks clear");
	imageCalculator("Difference", list1[i],"Mask of "+list1[i]);
	if (isOpen("Mask of "+list1[i])) { 
		selectWindow("Mask of "+list1[i]); 
		run("Close");
	}
	if (isOpen(list1[i])) { 
		selectWindow(list1[i]); 
	}
	width = getWidth;
	height = getHeight;
	for (y_Pos = 0; y_Pos < height; y_Pos++) {
		x_low=999999;
		x_high=0;
		makeLine(0, y_Pos, width, y_Pos);
		run("Clear Results");
		profile = getProfile();
		for (j_edge=1; j_edge<profile.length; j_edge++){
			x=j_edge;
			point_value=profile[j_edge];
			if (point_value>125) {//Detect white
				if (x>x_high) {//Lowest x
					x_high=x;
				}
				if (x<x_low) {
					x_low=x;
				}
			}
			if (x_low!=999999 && x_high!=0) { //white points detected
				if(fillEmpty){
					makeLine(x_low, y_Pos, x_high,y_Pos);
					run("Draw");
				}
			}
		}
		if (x_low>999000) {
			x_low=0;
		}
		Width_mean[y_Pos]=Width_mean[y_Pos]*((i)/(i+1))+(x_high-x_low)/(i+1); 			//Equation for average
		DistanceEdge_mean[y_Pos]=DistanceEdge_mean[y_Pos]*((i)/(i+1))+x_low/(i+1); 		//Equation for average
	}
	if(closePictures){
		if (i-1>0) {
			if (isOpen(list1[i-2])) { 
				selectWindow(list1[i-2]); 
				run("Close"); 
			}
		}
	}
}
for (y_Pos = 0; y_Pos < height - 20; y_Pos++) {
	if (Width_mean[y_Pos]<average_cut) {
		Width_mean[y_Pos]=0;
		DistanceEdge_mean[y_Pos]=0;
	}
}
if (set_batch) {
	setBatchMode(false);
}
if(printingWindows){
	count=0;
	maximum_pool_width=Width_mean[y_maximum_pool];
	if (isOpen("Results_profile")) {
		selectWindow("Results_profile");
		print(f1, "\\Headings: \t \t ");
		print(f1,"Maximum_pool_location:"+"\t"+y_maximum_pool*pixelSize+"\t"+"[mm]");
		print(f1,"Maximum_width:"+"\t"+maximum_pool_width*pixelSize+"\t"+"[mm]");
		print(f1,"Y_[mm]\tX_left[mm]\tWidth_[mm]");
		for (y_Pos = 0; y_Pos < height - 20; y_Pos++) {
			if (y_Pos < y_maximum_pool && Width_mean[y_Pos]>average_cut) {
				DistanceEdge_mean[y_Pos]= x_average_maximum_pool-Width_mean[y_Pos]/2;
			}
			print(f1, y_Pos*pixelSize+"\t"+DistanceEdge_mean[y_Pos]*pixelSize+"\t"+Width_mean[y_Pos]*pixelSize);
		}
	} 
}
if (set_batch) {
	setBatchMode(true);
}
if(closePictures){
	if (isOpen(list1[i-1])) { 
		selectWindow(list1[i-1]); 
		run("Close"); 
	}
	if (isOpen(list1[i-2])) { 
		selectWindow(list1[i-2]); 
		run("Close"); 
	}
}
if (printingTxt) {
	if (isOpen("Results_profile")) {
		selectWindow("Results_profile"); 
		saveAs("results",dir1+title1+".txt");
	}
}
if (isOpen("Log")) {
	if (isOpen("Log")) { 
		selectWindow("Log"); 
		run("Close"); 
	}
} 
if (isOpen("Results")) {
	if (isOpen("Results")) { 
		selectWindow("Results"); 
		run("Close"); 
	} 																		
}
if (printAverageImage) {
	open(dir1 + "zbackground.bmp");
	imageCalculator("Subtract create", "zbackground.bmp","zbackground.bmp");
	if (isOpen("zbackground.bmp")) { 
		selectWindow("zbackground.bmp"); 
		run("Close"); 
	}
	if (isOpen("Result of zbackground.bmp")) { 
		selectWindow("Result of zbackground.bmp"); 
	}
	width = getWidth;
	height = getHeight;
	for (y_Pos = 0; y_Pos < height; y_Pos++) {
		if (y_Pos < y_maximum_pool && Width_mean[y_Pos]>average_cut) {
			DistanceEdge_mean[y_Pos]= x_average_maximum_pool-Width_mean[y_Pos]/2;
		}
		if (DistanceEdge_mean[y_Pos]!=0) {
			makeLine(DistanceEdge_mean[y_Pos], y_Pos, Width_mean[y_Pos] + DistanceEdge_mean[y_Pos], y_Pos); 
			run("Draw");
		}
	}
	saveAs("BMP", dir1 + "average.bmp");
}
if (printAverageImage2) {
	open(dir1 + "zbackground.bmp");
	imageCalculator("Subtract create", "zbackground.bmp","zbackground.bmp");
	if (isOpen("zbackground.bmp")) { 
		selectWindow("zbackground.bmp"); 
		run("Close"); 
	}
	if (isOpen("Result of zbackground.bmp")) { 
		selectWindow("Result of zbackground.bmp"); 
	}
	width = getWidth;
	height = getHeight;
	for (y_Pos = 0; y_Pos < height; y_Pos++) {
		if (DistanceEdge_mean[y_Pos]!=0) {
			makeLine((width-Width_mean[y_Pos])/2, y_Pos, (width+Width_mean[y_Pos])/2, y_Pos); 
			run("Draw");
		}
	}
	saveAs("BMP", dir1 + "averageTwo.bmp");
}
if (closeAveragePictures) {
	if (isOpen("average.bmp")) { 
		selectWindow("average.bmp"); 
		run("Close"); 
	}
	if (isOpen("averageTwo.bmp")) { 
		selectWindow("averageTwo.bmp"); 
		run("Close"); 
	}
}
if (closeResultsFilm) {
	if (isOpen("Results_profile")) { 
		selectWindow("Results_profile"); 
		run("Close"); 
	}
}
if (closeTestResults) {
	if (isOpen("TESTS")) { 
		selectWindow("TESTS"); 
		run("Close"); 
	}
}
if (isOpen("Threshold")) { 
	selectWindow("Threshold"); 
	run("Close"); 
}
/////////////////////////////////////////////////////////////////////////////
}else{
	if (isOpen("Warning_files")) {
		selectWindow("Warning_files");
		titlefiles = "Warning_files"; 
		titlefiles2 = "["+titlefiles+"]"; 
		ffiles=titlefiles2;
		print(ffiles, dir1); 
	}else{
		titlefiles = "Warning_files"; 
		titlefiles2 = "["+titlefiles+"]"; 
		ffiles=titlefiles2; 
		run("New... ", "name="+titlefiles2+" type=Table"); 
		print(ffiles, "\\Headings:Warning!!!");
		print(ffiles, "Script did not find the correct images in folder");
		print(ffiles, "Consider checking zbackground and zstandard files");
		selectWindow("Warning_files");
		print(ffiles, dir1);  
	}
	if (isOpen("Log")) {
		selectWindow("Log"); 
		run("Close"); 
	} 
	if (isOpen("Results")) { 
		selectWindow("Results");
		run("Close"); 
	}
	if (closeTestResults) {
		if (isOpen("TESTS")) { 
			selectWindow("TESTS");
			run("Close"); 
		}
	}
	if (closeResultsFilm) {
		if (isOpen("Results_profile")) { 
			selectWindow("Results_profile"); 
			run("Close"); 
		}
	}
}
/////////////////////////////////////////////////////////////////////////////
print("The script is finished!");