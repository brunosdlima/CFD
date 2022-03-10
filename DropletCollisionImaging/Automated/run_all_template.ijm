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
for (countdir1 = 0; countdir1 < list_all.length-2; countdir1++){
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
			/*****************************************************************
					Insert here script to run side scripts
			 ****************************************************************/
			//Running front script
			dir1=dir_run_all4+list_all4[1];
			print(ffolder,dir1);
			/*****************************************************************
					Insert here script to run front scripts
			 ****************************************************************/
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