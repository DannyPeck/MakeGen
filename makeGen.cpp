#include <iostream>
#include <vector>
#include <fstream>

using namespace std;

// Takes in the exeFile and vector of rootFiles
string createExeTarget(string exeFile, vector<string>& rootFiles) {
    
    // Generates the target from the parameters to match makefile requirements
    string exeTarget = exeFile + ": ";

    for(int i = 0; i < rootFiles.size(); i++) {
	exeTarget += rootFiles.at(i) + ".o ";
    }

    exeTarget += "\n\t";
    exeTarget += "g++ ";
    
    for(int j = 0; j < rootFiles.size(); j++) {
	exeTarget += rootFiles.at(j) + ".o ";
    }

    exeTarget += "-o " + exeFile;

    return exeTarget;
}

// Takes in the objFile and vector of dependencies
string createObjTarget(string objFile, vector<string>& dependencies) {
    
    // Generates the target for each objFile from the dependencies
    string objTarget = objFile + ".o: ";
    for(int i = 0; i < dependencies.size(); i++) {
	objTarget += dependencies.at(i) + " ";
    }

    objTarget += "\n\t";
    objTarget += "g++ -c " + objFile + ".cpp";
    objTarget += "\n\n";

    return objTarget;
}

// Takes in the exeFile and generates the clean target for makefile
string createCleanTarget(string exeFile) {
    string clean = "clean:";
    clean += "\n\t";
    clean += "rm *.o " + exeFile;
    return clean;
}

// takes in array of command line arguments
int main(int argc, char** argv) {

    // stores them in a vector of fileNames
    vector<string> rootFiles;
    vector<string> cppFiles;
    
    // last arguement should be the directory name, which i will use for exe
    string executableFile = argv[argc-1]; 

    // for each file in the vector, if it is a .cpp file add it to executable 
    int pos;
    string token;

    // Represents each file we are searching through
    string fileName;

    // for each file in the arguments, excluding our file name (argv[0])
    for(int i = 1; i < argc; i++){
	
	// grabs each file from the arguments array
	fileName = argv[i];
	
	/* 
	This is a kind of hack, because both the include statements
	and the .cpp files contain ".cpp" the first if statement removes
	the include statement cases for the other if statement
	*/
	if((pos = fileName.find(".cpp:")) != string::npos){
	
	}

	// if the string contains ".cpp"
	else if((pos = fileName.find(".cpp")) != string::npos) {
	    // add it to the vector of cpp files
	    cppFiles.push_back(fileName);

	    // token out the root file name and add it to the rootFiles vector
	    token = fileName.substr(0, pos);
	    rootFiles.push_back(token);
	}
    }
    string mark = "#--------------------------------------------";
    // We begin creating our makefile by creating the executable target
    string makefile = mark + "\n\n";
    makefile += createExeTarget(executableFile, rootFiles);
    
    // add in the proper spacing
    // Note: won't let me chain in these characters with other strings so they are seperate line
    makefile += "\n\n";
    
    // For each rootFile, check from the include statements for their respective dependencies
    for(int j = 0; j < rootFiles.size(); j++) {
	// specifies the current iterations rootFile
	fileName = rootFiles.at(j);

	// creates the current iterations vector of dependencies
	vector<string> dependencies;

	// adds the rootFiles cpp file first
	dependencies.push_back(fileName + ".cpp");

	// for each file in the argument, check for the include statement format
	for(int k = 1; k < argc; k++) {
	    string element = argv[k];
	    if((pos = element.find(".cpp:")) != string::npos) {
		// if the include statement is for the current rootFile, add it to the dependencies
		// include statements follow the format: root.cpp:value
		// checks for root to check against the fileName
		if(element.substr(0, pos) == fileName){
		    // Grabs the value and pushes it into dependency vector
		    string data = element.substr(pos + 5, string::npos);
		    dependencies.push_back(data);
		}
	    }
	}
	
	// for each rootFile, create a new target and append it to the makefile
	makefile += createObjTarget(rootFiles.at(j), dependencies);
    }
    
    // after the exeTarget and all objTargets have been created, add the clean target
    makefile += createCleanTarget(executableFile);

    makefile += "\n\n";
    makefile += mark;
    
    // Creates the makefile and pushes the makefile text into it
    ofstream outFile("makefile");
    outFile << makefile << endl;
    outFile.close();

    // Note: the script will take care of moving the makefile to specified directory and running make

    return 0;
}
