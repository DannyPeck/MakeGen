#!/bin/sh

# converts all files in directory to unix to remove ^M
# redirects the annoying dos2unix output into oblivion
dos2unix $1/* 2> /dev/null

# if there is not a directory arugment passed in
# then print error, clean up and exit

sanitize() {
    if [ ! $1 ] ; then
	echo "Did not specify directory arguement: MakeGen [Directory Name]"
	return 1;
    elif [ ! -d $(pwd)/$1 ] ; then
	echo "The given argument is not a valid directory"
	return 1;
    else
	return 0;
    fi
}

arg=$2

if [ $1 = "-j" ] ; then
    if sanitize $2 ; then
	echo "Java"	
    fi
# if they did pass us a directory then list all of the files and find the .cpp's 
elif [ $1 = "-cpp" ] ; then
    if sanitize $2 ; then
	echo "Cpp"
    fi
elif sanitize $1 ; then
    arg=$1

    # compiles the makeGen cpp program might be to specific at the moment
    g++ /usr/local/bin/MakeGen/makeGen.cpp -o makeG

    cppFiles=$(ls -a $arg | grep .cpp)

    # if there actually are cppFiles
    if [ ! -z "$cppFiles" ] ; then
	# this command searches all of the .cpp files for user created include statements (#include "Book.h")
	# and formats it into an exceptable format for passing into the makeGen c++ program for further parsing and manipulation
	includes=$(grep -i "#include" $arg/*.cpp | sed 's/.*>//g' | sed 's/#include//g' | sed 's/.*\///g' | sed 's/\"//g' | sed 's/: /:/g')
	
	# allows the command to work from any directory from within the local user
	dir=$(basename $arg)
	
	# runs the makeGen.cpp program with the cppFiles, include statements and directory argument
	./makeG $cppFiles $includes $dir
	
	# clean up the current directory
	rm makeG

	# move the makefile into the given directory
	mv ./makefile $arg/

	# run the make command and back out
	cd $arg
	make
	cd $(pwd)
    else
	# report error and clean up directory
	echo "No .cpp files found in directory"
	rm makeG
    fi
fi
