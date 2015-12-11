#!/bin/sh

# converts all files in directory to unix to remove ^M
# redirects the annoying dos2unix output into oblivion
dos2unix $1/* 2> /dev/null

# runs a given argument through a series of checks
sanitize() {
    if [ ! $1 ] ; then
	echo "Did not specify directory arguement: MakeGen [Directory Name]"
	return 1;

    elif [ ! -d $(pwd)/$1 ] ; then
	echo "The given arguments are invalid, try: MakeGen [-j, -cpp] [Directory Name]"
	return 1;
    else
	return 0;
    fi
}

# Script code required to build the C++ makefiles
cpp() {
    # compiles the makeGen cpp program might be to specific at the moment
    g++ makeGen.cpp -o makeG
    
    cppFiles=$(ls -a $1 | grep .cpp)

    # if there actually are cppFiles
    if [ ! -z "$cppFiles" ] ; then
	# this command searches all of the .cpp files for user created include statements (#include "Book.h")
	# and formats it into an exceptable format for passing into the makeGen c++ program for further parsing and manipulation
	includes=$(grep -i "#include" $1/*.cpp | sed 's/.*>//g' | sed 's/#include//g' | sed 's/.*\///g' | sed 's/\"//g' | sed 's/: /:/g')
	
	# allows the command to work from any directory from within the local user
	dir=$(basename $1)
	
	cppFlag="cpp"
	# runs the makeGen.cpp program with the cppFiles, include statements and directory argument
	./makeG $cppFlag $cppFiles $includes $dir
	
	# clean up the current directory
	rm makeG

	# move the makefile into the given directory
	mv ./makefile $1/

	# run the make command and back out
	cd $1
	make
	cd $(pwd)
    else
	# report error and clean up directory
	echo "No .cpp files found in directory"
	rm makeG
    fi
}

# Script code required to build a Java makefile
java() {
    
    # compiles the makeGen cpp program might be to specific at the moment
    g++ makeGen.cpp -o makeG

    javaFiles=$(ls -a $1 | grep .java)
    
    if [ ! -z "$javaFiles" ] ; then
	
	mainPath=$(grep -i "static void main(" $1/*.java | sed 's/:.*//g');
	
	main=$(basename $mainPath | sed 's/.java//g')

	dir=$(basename $1)
	
	javaFlag="java"

	./makeG $javaFlag $main $dir
	
	rm makeG

	# move the makefile into the given directory
	mv ./makefile $1/

	# run the make command and back out
	cd $1
	make
	cd $(pwd)

    else
	echo "No .java files found in directory"
	rm makeG
    fi

}

if [ $1 = "-j" ] ; then
    if sanitize $2 ; then
	java $2
    fi
# if they did pass us a directory then list all of the files and find the .cpp's 
elif [ $1 = "-cpp" ] ; then
    if sanitize $2 ; then
	cpp $2
    fi
elif sanitize $1 ; then
    cpp $1
fi
