/* 
This script runs the scripts for front and side for a path similar to the one below:
C:\Users\Bruno Lima\Desktop\runall\200\closer\1
Inside "1" there must be two folders, the first one containing images for the side camera and the second one containing images for the front.
To insert the routines the old line "dir1 = getDirectory("Choose Source Directory ");" must be commented.
*/
//Variables for printing and saving files
printingWindowsForCurrentFolder=true;			//Opening window showing current working folder
if (printingWindowsForCurrentFolder) {
	Current_Working_Folder_Closing=false;			//Closing window showing current working folder
}
//Starting counting variables for folders
countdir1=0;
countdir2=0;
countdir3=0;
//Creating windows on Fiji
if(printingWindowsForCurrentFolder){
	titlefolder = "Current_Working_Folder"; 
	title2folder = "["+titlefolder+"]"; 
	ffolder=title2folder; 
	run("New... ", "name="+title2folder+" type=Table"); 
	print(ffolder, "\\Headings:\tCurrent_folder");

}
dir_run_all = getDirectory("Choose Source Directory ");
dir_run_all = replace(dir_run_all, "\\", "/");
list_all = getFileList(dir_run_all);
for (countdir1 = 0; countdir1 < list_all.length; countdir1++){
	dir_run_all2=dir_run_all+list_all[countdir1];
	list_all2 = getFileList(dir_run_all2);
	for (countdir2 = 0; countdir2 < list_all2.length; countdir2++){
		dir_run_all3=dir_run_all2+list_all2[countdir2];
		list_all3 = getFileList(dir_run_all3);
		for (countdir3 = 0; countdir3 < list_all3.length; countdir3++){
			dir_run_all4=dir_run_all3+list_all3[countdir3];
			list_all4 = getFileList(dir_run_all4);
			//Running side script
			dir1=dir_run_all4+list_all4[0];
			print(ffolder,dir1);
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
dropletFiltered=0.65; 			//Variable used to filter the splashed droplets
search_pool=100;				//Variable used to look for maximum width of the pool
average_cut=7;					//Variable used to define the top of the pool
subtract_background=40;			//Variable used to set background rolling
set_threeshold=30;				//Variable used to set threeshold
// Combining zbackground and image then making binary and fililing holes
list1 = getFileList(dir1);
if (File.exists(dir1 + "zbackground.bmp") && File.exists(dir1 + "zstandard.bmp") && !File.exists(dir1 + "average.bmp")) { //Check if zbackground and zstandard are on the working folder and if there is the average file
//Working with the list of images
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
	for (y_Pos = 0; y_Pos < height; y_Pos++) {
			if (DistanceEdge_mean[y_Pos]==0) {
				
			}else {
				maximum_pool_width=Width_mean[y_Pos];
				count++;
				if (count>search_pool) {
					y_Pos=height;
				}
			}
	}
	if (isOpen("Results_profile")) {
		selectWindow("Results_profile");
		print(f1, "\\Headings: \t \t ");
		print(f1,"Maximum_pool_width:"+"\t"+maximum_pool_width+"\t"+"[mm]");
		print(f1,"Y_[mm]\tX_left[mm]\tWidth_[mm]");
		for (y_Pos = 0; y_Pos < height - 20; y_Pos++) {
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
			//Running front script
			dir1=dir_run_all4+list_all4[1];
			print(ffolder,dir1);
			/* 
This script calculates the average of the film height profile and the angle of impact of droplets in a chosen folder.
Make sure to change the values of fps and pixel size in the section Input variables. Also change the tunning variables if necessary.
Make sure that there are in the chosen folder the following files: "zbackground.bmp" and "zstandard.bmp". This files are used to calculate the reflection of the plate.
Considering the alphabetical order your sequence of images should come before "zbackground.bmp" and "zstandard.bmp".
It must not contain any other files. After printing results as txt files you need to remove it from the folder in order to run the script again.
Pay attention on setting the values of brightness and colour as well as threshold.
*/
//Variables for printing and saving files
printingWindows=true;				//Print results to new windows on Fiji
if (printingWindows) {
	closeResultsDroplet=true;		//Close results of droplets window (only make it true if printingWindows is true)
	closeResultsFilm=true;			//Close results of film windows (only make it true if printingWindows is true)
	closeTestResults=true;			//Close results window for testing (only make it true if printingWindows is true)
	printingTxt=true;				//Print results to txt files (only make it true if printingWindows is true)
}
closePictures=true;  				//Close working pictures
printAverageImage=true;				//Print the average image for film thickness
closeAveragePictures=true;			//Close average images
set_batch=true;  					//Setting batch makes the script run faster by not opening the images
set_Threshold=false; 				//Set values threshold according to fine tuning parameters
set_BrightnessAndColour=false; 		//Set values for brightness and colour according to fine tuning parameters
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
if (isOpen("Droplet_average")) { 
		selectWindow("Droplet_average");
		run("Close"); 
	}
if (isOpen("TESTS")) { 																		
	selectWindow("TESTS"); 
	run("Close"); 
}
if (isOpen("Results_film_liquid_height")) { 																		
	selectWindow("Results_film_liquid_height"); 
	run("Close"); 
}
//Creating windows on Fiji
if(printingWindows){
	title1 = "Results_impacted"; 
	title2 = "["+title1+"]"; 
	f1=title2; 
	run("New... ", "name="+title2+" type=Table"); 
	print(f1, "\\Headings:X_[mm]\tY_[mm]\tArea_[mm2]\tWidth_[mm]\tHeight_[mm]\tCirc\tAR\tRound\tSolidity\tDrop_ID\tVx_[mm/s]\tVy_[mm/s]\tImpact_Angle_[degrees]");
	title3 = "Results_film_liquid_height"; 
	title4 = "["+title3+"]"; 
	f2=title4; 
	run("New... ", "name="+title4+" type=Table"); 
	print(f2, "\\Headings:Distance_along_wall_[mm]\tFilm_Height_[mm]");
	title7 = "Droplet_average"; 
	title8 = "["+title7+"]"; 
	f4=title8; 
	run("New... ", "name="+title8+" type=Table");
	print(f4, "\\Headings:X_[mm]\tY_[mm]\tArea_[mm2]\tWidth_[mm]\tHeight_[mm]\tCirc\tAR\tRound\tSolidity\tNumber_of_collisions\tVx_[mm/s]\tVy_[mm/s]\tV_Mag_[mm/s]\tImpact_Angle_[degrees]");
	title5 = "TESTS"; 
	title6 = "["+title5+"]"; 
	f3=title6; 
	run("New... ", "name="+title6+" type=Table");
}
//Input variables (change for your case)
fps=10000; 								//frames per second [1/s]
pixelSize=14/835; 						//size of each pixel [mm/pixel]
//Fine tune parameters
countourRectangleSize=10; 				//Variable used to check around the droplet for collision
percentageOfPictureToCheck=60; 			//Variable to check for droplets on each of the images
distanceNewOrCollision=25;    			//Variable used to check for new droplets and collision
AdjustMinimumMeanSquareError=1/1000;    //Variable used to adjust the minimum mean square error approximation for impact angle
AdjustMinimumMeanSquareError2=5;        //Variable used to adjust the minimum mean square error approximation for impact angle
lvt=10;									//Lower value for threshold 
gvt=99;									//Greater value for theshold
lvcb=0;								//Lower value to adjust brightness and contrast of list images
gvcb=80;								//Greater value to adjust brightness and contrast of list images
// Combining zbackground and image then making binary and fililing holes
list1 = getFileList(dir1);
if (File.exists(dir1 + "zbackground.bmp") && File.exists(dir1 + "zstandard.bmp") && !File.exists(dir1 + "average.bmp")) { //Check if zbackground and zstandard are on the working folder and if there is the average file
open(dir1 + "zbackground.bmp");
open(dir1 + "zstandard.bmp");
imageCalculator("Difference create", "zbackground.bmp","zstandard.bmp");
if (isOpen("Result of zbackground.bmp")) { 																		
	selectWindow("Result of zbackground.bmp"); 
}
if (set_BrightnessAndColour) {
	setMinAndMax(lvcb, gvcb);
	run("Apply LUT"); 
}
if (set_Threshold) {
	setAutoThreshold("Default");
	run("Threshold...");
	setThreshold(lvt, gvt);
}
run("Convert to Mask");
if (isOpen("Threshold")){ 																		
	selectWindow("Threshold");
	run("Close");
}
run("Make Binary");
run("Fill Holes");
if (isOpen("zbackground.bmp")) { 
	selectWindow("zbackground.bmp");
	run("Close"); 
}
if (isOpen("zstandard.bmp")) { 
	selectWindow("zstandard.bmp");
	run("Close"); 
}
if (isOpen("Result of zbackground.bmp")) { 																		
	selectWindow("Result of zbackground.bmp"); 
}
width = getWidth;
height = getHeight;
// Find the edge of the images cutting and rotating
//Finding nearest droplet and its reflection
makeRectangle(0, 0, width, height);
run("Set Measurements...", "area centroid bounding redirect=None decimal=3");
run("Analyze Particles...", "size=80-Infinity show=Nothing display exclude clear");
n=nResults;
x1=x2=getResult ("X", 0);
y1=y2=getResult ("Y", 0);
//the higher value of y is stored on y1
for (i = 0; i < n; i++) {
	newy = getResult ("Y", i);
	if (y1 < newy) {
		y1=newy;
		x1= getResult ("X", i);
	}
}
//the second higher value of y is stored on y2
for (i = 0; i < n; i++) {
	newy = getResult ("Y", i);
	if (y2 < newy) {
		if (y2 < y1 - 1) {
			y2=newy;
			x2= getResult ("X", i);
		}
	}
}
//Finding the vector normal to the midle point of the droplets
dx = (x1 - x2)/2;
dy = (y1 - y2)/2 ;
Xmid = x2 + dx;
Ymid = y2 + dy;
k = -(x2-x1)/(y2-y1);
Y_0 = k*(0-Xmid)+Ymid; 
X_0 = Xmid -Ymid/k;
teta=(acos((X_0)/(sqrt(X_0*X_0+Y_0*Y_0)))*(180/PI)-90);
if (isOpen("Result of zbackground.bmp")) { 
	selectWindow("Result of zbackground.bmp");
	run("Close"); 
}
if (teta>0 || teta<0 || teta==0) {				//If teta is not numeric you may consider refining the fine tuning variables
//Working with the list of images
setOption("ExpandableArrays", true);
DistanceEdge_mean= newArray();
y_mean= newArray();
droplet_average=newArray(0,0,0,0,0,0,0,0,0,0,0,0,0);
lenghtlist=list1.length;
drop_count=0;
xDropletOld = newArray(0,0,0);
yDropletOld = newArray(0,0,0);
dropletnew = newArray(0,0,0,0,0,0,0,0,0,0,0,0,0);
dropletold = newArray(0,0,0,0,0,0,0,0,0,0,0,0,0);
for (y_Pos = 0; y_Pos < height+200; y_Pos++) {
	DistanceEdge_mean[y_Pos]=0;
}
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
	if (set_BrightnessAndColour) {
		setMinAndMax(lvcb, gvcb);
		run("Apply LUT"); 
	}
	if (set_Threshold) {
		setAutoThreshold("Default");
		run("Threshold...");
		setThreshold(lvt, gvt);
	}
	run("Convert to Mask");
	if (isOpen(list1[i])) { 
		selectWindow(list1[i]);
	}
	run("Make Binary");
	run("Fill Holes");
	//Rotating image according to "Finding the vector normal to the midle point of the droplets" section
	//print(f3,teta);
	run("Rotate... ", "angle=teta grid=1 interpolation=None");
	newx=X_0+height/k;
	width = getWidth;
	height = getHeight;
	makePolygon(newx,0, width,0, width,height, newx,height);
	run("Clear Outside");
	run("Crop");
	run("Make Binary");	
	//After rotating and croping the values of height and width are updated
	width = getWidth;
	height = getHeight;
	//Calculating the average of film thickness along the wall over all images
	for (y_Pos = 0; y_Pos < height; y_Pos++) {
		makeLine(0, y_Pos, width, y_Pos);
		run("Clear Results");
		profile = getProfile();
		for (j_edge=1; j_edge<profile.length; j_edge++){
			if(profile[j_edge]<=profile[j_edge-1]*0.8){
				DistanceEdge=j_edge-1;
				j_edge=profile.length;
			}
		}
		DistanceEdge_mean[y_Pos]=DistanceEdge_mean[y_Pos]*((i)/(i+1))+DistanceEdge/(i+1); //Equation for average
	}
	//Finding velocity and angle of impact for droplets and saving droplets
	//Finding the droplets inside the domain
	setTool("rectangle");
	makeRectangle(0, 0, width, height*percentageOfPictureToCheck/100);
	run("Set Measurements...", "area centroid bounding redirect=None decimal=3");
	run("Analyze Particles...", "size=80-Infinity show=Nothing display exclude clear");
	numDrop=nResults;															//number of droplets inside the domain
	setTool("rectangle");
	makeRectangle(0, 0, width, height*percentageOfPictureToCheck/100);
	run("Set Measurements...", "area centroid bounding shape redirect=None decimal=3");
	run("Analyze Particles...", "size=80-Infinity show=Nothing display exclude clear");
	if (nResults>0) {                                                          //Only run droplet script if there are droplets
		//The highest value of y is stored on y1, and for x in x1
		x1=getResult ("X", 0);
		y1=getResult ("Y", 0);
		dropletold[0]=dropletnew[0];
		dropletold[1]=dropletnew[1];
		dropletold[2]=dropletnew[2];
		dropletold[3]=dropletnew[3];
		dropletold[4]=dropletnew[4];
		dropletold[5]=dropletnew[5];
		dropletold[6]=dropletnew[6];
		dropletold[7]=dropletnew[7];
		dropletold[8]=dropletnew[8];
		dropletold[9]=dropletnew[9];
		dropletnew[0]=getResult ("X", 0); 
		dropletnew[1]=getResult ("Y", 0); 
		dropletnew[2]=getResult ("Area", 0);
		dropletnew[3]=getResult ("Width", 0);
		dropletnew[4]=getResult ("Height", 0);
		dropletnew[5]=getResult ("Circ.", 0);
		dropletnew[6]=getResult ("AR", 0);
		dropletnew[7]=getResult ("Round", 0);
		dropletnew[8]=getResult ("Solidity", 0);
		dropletnew[9]=i;
		//Finding the droplet which is closest to the wall
		print("\\Clear");
		for (j = 0; j < numDrop; j++) {
			newx = getResult ("X", j);
			newy = getResult ("Y", j);
			if (x1 > newx) {		
				x1=newx;
				y1=newy;
				dropletnew[0]=getResult ("X", j); 
	   			dropletnew[1]=getResult ("Y", j); 
	   			dropletnew[2]=getResult ("Area", j);
	   			dropletnew[3]=getResult ("Width", j);
	   			dropletnew[4]=getResult ("Height", j);
	   			dropletnew[5]=getResult ("Circ.", j);
	   			dropletnew[6]=getResult ("AR", j);
	   			dropletnew[7]=getResult ("Round", j);
	   			dropletnew[8]=getResult ("Solidity", j);
				dropletnew[9]=i; //ID
			}
		}
		xDropletOld[0]=xDropletOld[1];
		xDropletOld[1]=xDropletOld[2];
		xDropletOld[2]=x1;
		yDropletOld[0]=yDropletOld[1];
		yDropletOld[1]=yDropletOld[2];
		yDropletOld[2]=y1;
		//Calculating velocity
		if (yDropletOld[0] != 0 && yDropletOld[1] != 0) { 				//Checking if it is not in the first two images
			dropletnew[10]=(xDropletOld[1]-xDropletOld[0])*fps;			//Vx [pixels per second]
			dropletnew[11]=(yDropletOld[1]-yDropletOld[0])*fps;			//Vy [pixels per second]
		}
		Vx=dropletnew[10];                   		     				//Velocity in pixels per second
		Vy=dropletnew[11];             					 				//Velocity in pixels per second
		//Calculating the impact angle
		if (yDropletOld[0] != 0 && yDropletOld[1] != 0) { 				//Checking if it is not in the first two images
			if (xDropletOld[2] > xDropletOld[1]) { 						//Condition for collision is if the last droplet detected has a lower x than last image
				if (isOpen(list1[i-1])) { 
					selectWindow(list1[i-1]);							//Select one image before the impact
				}
				angleOfVelocity=(atan(Vx/Vy));							//Angle in radians
				//print(f3,"angleOfVelocity");
				//print(f3,angleOfVelocity*180/PI);
				y_0=yDropletOld[0]-(xDropletOld[0]/(Vx/Vy));
				makeLine(0, y_0,xDropletOld[0], yDropletOld[0]);
				//print(f3,y_0);
				//print(f3,xDropletOld[0]);
				//print(f3,yDropletOld[0]);
				run("Set Measurements...", "area mean centroid redirect=None decimal=3");
				setTool("point");
				fivePointsArray= newArray(0,0,0,0,0,0,0,0,0,0);
				print("\\Clear");
				for (h = 0; h < 5; h++) {// Obtaining the point where colision happened and its neighbours
					count=0;
					xf=0;
					yf=y_0+(h-2)*AdjustMinimumMeanSquareError2;
					makePoint(xf, yf, "small yellow circle");
					run("Clear Results");
					run("Measure");
					lastPoint=getResult("Mean", 0);
					while (lastPoint>125) { //Check for first point out of the film liquid in droplet direction
						run("Clear Results");
						xf=xf+AdjustMinimumMeanSquareError*count;
						yf=yf+(AdjustMinimumMeanSquareError*count)/(Vx/Vy);
						makePoint(xf, yf, "small yellow circle");
						run("Measure");
						lastPoint=getResult("Mean", 0);
						count++;
					}
					makePoint(xf, yf, "small yellow circle");
					fivePointsArray[2*h]=xf;
					fivePointsArray[2*h+1]=yf;				
				}
				// Minimum squares method to obtain the equation of the line (http://www.decom.ufop.br/prof/marcone/Disciplinas/MetodosNumericoseEstatisticos/QuadradosMinimos.pdf)
				sumX=fivePointsArray[0]+fivePointsArray[2]+fivePointsArray[4]+fivePointsArray[6]+fivePointsArray[8];
				sumY=fivePointsArray[1]+fivePointsArray[3]+fivePointsArray[5]+fivePointsArray[7]+fivePointsArray[9];
				sumX2=fivePointsArray[0]*fivePointsArray[0]+fivePointsArray[2]*fivePointsArray[2]+fivePointsArray[4]*fivePointsArray[4]+fivePointsArray[6]*fivePointsArray[6]+fivePointsArray[8]*fivePointsArray[8];
				sumXY=fivePointsArray[0]*fivePointsArray[1]+fivePointsArray[2]*fivePointsArray[3]+fivePointsArray[4]*fivePointsArray[5]+fivePointsArray[6]*fivePointsArray[7]+fivePointsArray[8]*fivePointsArray[9];
				// y = a*x + b
				equationA=(sumY-(5*sumXY)/sumX)/(sumX-(5*sumX2)/sumX);
				equationB=(sumY-(sumX*sumXY)/sumX2)/(5-(sumX*sumX)/sumX2);
				if(printingWindows){
					//print(f3,"equationA");
					//print(f3,equationA);
					//print(f3,"equationB");
					//print(f3,equationB);
				}
				makeLine(0, equationB, 50, equationA*50 + equationB);
				//run("Draw");
				alpha=(PI/2)+angleOfVelocity;
				beta=(PI+atan(-equationA));
				impactAngle=-atan((tan(beta)-tan(alpha))/(1+tan(beta)*tan(alpha))); // (y direction is downwards in Fiji) https://www.somatematica.com.br/emedio/retas/retas10.php 
				dropletnew[12]=impactAngle*180/PI;                 //Impact angle in degrees
				if (dropletnew[12]<0) {
					if(printingWindows){
						print(f1, dropletold[0]*pixelSize+"\t"+dropletold[1]*pixelSize+"\t"+dropletold[2]*pixelSize*pixelSize+"\t"+dropletold[3]*pixelSize+"\t"+dropletold[4]*pixelSize+"\t"+dropletold[5]+"\t"+dropletold[6]+"\t"+dropletold[7]+"\t"+dropletold[8]+"\t"+dropletold[9]+"\t"+dropletnew[10]*pixelSize+"\t"+dropletnew[11]*pixelSize+"\t"+dropletnew[12]);	
					}
					//Calculating average parameters for droplet (makes no sense for ID)
					droplet_average[0]=droplet_average[0]*(drop_count/(drop_count+1))+(dropletold[0]/(drop_count+1)); 
   					droplet_average[1]=droplet_average[1]*(drop_count/(drop_count+1))+(dropletold[1]/(drop_count+1)); 
   					droplet_average[2]=droplet_average[2]*(drop_count/(drop_count+1))+(dropletold[2]/(drop_count+1));
	   				droplet_average[3]=droplet_average[3]*(drop_count/(drop_count+1))+(dropletold[3]/(drop_count+1));
   					droplet_average[4]=droplet_average[4]*(drop_count/(drop_count+1))+(dropletold[4]/(drop_count+1));
   					droplet_average[5]=droplet_average[5]*(drop_count/(drop_count+1))+(dropletold[5]/(drop_count+1));
   					droplet_average[6]=droplet_average[6]*(drop_count/(drop_count+1))+(dropletold[6]/(drop_count+1));
   					droplet_average[7]=droplet_average[7]*(drop_count/(drop_count+1))+(dropletold[7]/(drop_count+1));
	   				droplet_average[8]=droplet_average[8]*(drop_count/(drop_count+1))+(dropletold[8]/(drop_count+1));
					droplet_average[10]=droplet_average[10]*(drop_count/(drop_count+1))+(dropletnew[10]/(drop_count+1));
					droplet_average[11]=droplet_average[11]*(drop_count/(drop_count+1))+(dropletnew[11]/(drop_count+1));
					droplet_average[12]=droplet_average[12]*(drop_count/(drop_count+1))+(dropletnew[12]/(drop_count+1));	
					drop_count++;	
					droplet_average[9]=drop_count;																			//instead of ID store drop_count
				}
			}
		}
	}
	if(closePictures){
		if (i-1>0){
			if (isOpen(list1[i-2])) {
				selectWindow(list1[i-2]);
				run("Close"); 
			}
		}
	}	
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
if (set_batch) {
	setBatchMode(false);
}
if(printingWindows){
	if (isOpen("Droplet_average")) {
		selectWindow("Droplet_average");
		print(f4, droplet_average[0]*pixelSize+"\t"+droplet_average[1]*pixelSize+"\t"+droplet_average[2]*pixelSize*pixelSize+"\t"+droplet_average[3]*pixelSize+"\t"+droplet_average[4]*pixelSize+"\t"+droplet_average[5]+"\t"+droplet_average[6]+"\t"+droplet_average[7]+"\t"+droplet_average[8]+"\t"+droplet_average[9]+"\t"+droplet_average[10]*pixelSize+"\t"+droplet_average[11]*pixelSize+"\t"+(sqrt((droplet_average[10]*pixelSize*droplet_average[10]*pixelSize)+(droplet_average[11]*pixelSize*droplet_average[11]*pixelSize)))+"\t"+droplet_average[12]); 
	}	
}
if(printingWindows){
	if (isOpen("Results_film_liquid_height")) {
		selectWindow("Results_film_liquid_height");
		for (y_Pos = 0; y_Pos < height - 20; y_Pos++) {
			print(f2, y_Pos*pixelSize+"\t"+DistanceEdge_mean[y_Pos]*pixelSize);
		}  
	}
}
if (set_batch) {
	setBatchMode(true);
}
if (printingTxt) {
	if (isOpen("Results_impacted")) {
		selectWindow("Results_impacted"); 
		saveAs("results",dir1+title1+".txt"); 
	} 
	if (isOpen("Results_film_liquid_height")) {
		selectWindow("Results_film_liquid_height");
		saveAs("results",dir1+title3+".txt"); 
	} 
	if (isOpen("Droplet_average")) {
		selectWindow("Droplet_average");
		saveAs("results",dir1+title7+".txt"); 
	}
}
if (isOpen("Log")) {
	selectWindow("Log"); 
	run("Close"); 
} 
if (isOpen("Results")) { 
	selectWindow("Results");
	run("Close"); 
}
if (closeResultsDroplet) {
	if (isOpen("Results_impacted")) { 
		selectWindow("Results_impacted");
		run("Close"); 
	}
}
if (closeResultsFilm) {
	if (isOpen("Results_film_liquid_height")) { 
		selectWindow("Results_film_liquid_height");
		run("Close"); 
	}
}
if (closeTestResults) {
	if (isOpen("TESTS")) { 
		selectWindow("TESTS");
		run("Close"); 
	}
}
if (closeResultsDroplet) {
	if (isOpen("Droplet_average")) { 
		selectWindow("Droplet_average");
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
	for (y_Pos = 0; y_Pos < height+20; y_Pos++) {
			if (DistanceEdge_mean[y_Pos]==0) {
				
			}else {
				makeLine(0, y_Pos, DistanceEdge_mean[y_Pos], y_Pos); 
				run("Draw");
			}
	}
	makeRectangle(0, 0, width, height-50);
	run("Duplicate...", " ");
	saveAs("BMP", dir1 + "average.bmp");
	if (isOpen("Result of zbackground.bmp")) { 
		selectWindow("Result of zbackground.bmp");
		run("Close"); 
	} 
}
if (closeAveragePictures) { 
	selectWindow("average.bmp"); 
	run("Close"); 
}
if (isOpen("Threshold")) { 
	selectWindow("Threshold"); 
	run("Close"); 
}
if (Current_Working_Folder_Closing) {
	if (isOpen("Current_Working_Folder")) { 
		selectWindow("Current_Working_Folder"); 
		run("Close"); 
	}	
}
////////////////////////////////////////////////////////////////////////////
//Error condition for non numerical teta
}else{
	if (isOpen("Warning")) {
		selectWindow("Warning"); 
		titleteta = "Warning"; 
		titleteta2 = "["+titleteta+"]"; 
		fteta=titleteta2;
		print(fteta, dir1); 
	}else{
		titleteta = "Warning"; 
		titleteta2 = "["+titleteta+"]"; 
		fteta=titleteta2; 
		run("New... ", "name="+titleteta2+" type=Table"); 
		print(fteta, "\\Headings:Warning!!!");
		print(fteta, "Non numerical value for rotating the images");
		print(fteta, "Consider changing the fine tuning variables");
		print(fteta, "This problem may occur when droplets cannot be identified");
		print(fteta, "List of error folders"); 
		print(fteta, dir1);
	}
	if (closeResultsDroplet) {
		if (isOpen("Results_impacted")) { 
			selectWindow("Results_impacted");
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
	if (closeResultsDroplet) {
		if (isOpen("Results_impacted")) { 
			selectWindow("Results_impacted");
			run("Close"); 
		}
	}
	if (closeResultsFilm) {
		if (isOpen("Results_film_liquid_height")) { 
			selectWindow("Results_film_liquid_height");
			run("Close"); 
		}
	}
	if (closeTestResults) {
		if (isOpen("TESTS")) { 
			selectWindow("TESTS");
			run("Close"); 
		}
	}
	if (closeResultsDroplet) {
		if (isOpen("Droplet_average")) { 
			selectWindow("Droplet_average");
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
if (isOpen("Warning")) {
	selectWindow("Warning");  
	titleteta = "Warning"; 
	titleteta2 = "["+titleteta+"]"; 
	fteta=titleteta2;
	saveAs("results",dir1+titleteta+".txt");
}
if (isOpen("Warning_files")) {
	selectWindow("Warning_files");
	titlefiles = "Warning_files"; 
	titlefiles2 = "["+titlefiles+"]"; 
	ffiles=titlefiles2;  
	saveAs("results",dir1+titlefiles+".txt");
}
if (isOpen("Log")) {
	selectWindow("Log"); 
	run("Close"); 
}
print("The script is finished!");
		}
	}
	
}
if (Current_Working_Folder_Closing) {
	if (isOpen("Current_Working_Folder")) { 
		selectWindow("Current_Working_Folder"); 
		run("Close"); 
	}	
}
if (isOpen("Log")) {
	selectWindow("Log"); 
	run("Close"); 
}
if (isOpen("Warning")) {
	selectWindow("Warning");  
	saveAs("results",dir_run_all+titleteta+".txt");
}
if (isOpen("Warning_files")) {
	selectWindow("Warning_files");  
	saveAs("results",dir_run_all+titlefiles+".txt");
}
print("All the scripts are finished!");