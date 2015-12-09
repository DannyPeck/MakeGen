#!/bin/sh

# converts all files in directory to unix to remove ^M
# redirects the annoying dos2unix output into oblivion
dos2unix $1/* 2> /dev/null

# comp iles the makeGen cpp program
g++ makeGen.cpp -o makeG

# if there is not a directory arugment passed in
# then print error, clean up and exit
if [ ! -d $1 ] || [ ! $1 ] ; then
    echo "Did not specify directory argument: ./makeGen [Directory Name]"
    rm makeG
    exit 0
# if they did pass us a directory then list all of the files and find the .cpp's 
else
    cppFiles=$(ls -a $1 | grep .cpp)
    if [ ! -z "$cppFiles" ] ; then
	# this command searches all of the .cpp files for user created include statements (#include "Book.h")
	# and formats it into an exceptable format for passing into the makeGen c++ program for further parsing and manipulation
	includes=$(grep -i "#include" $1/*.cpp | sed 's/.*>//g' | sed 's/#include//g' | sed 's/.*\///g' | sed 's/\"//g' | sed 's/: /:/g')

	# runs the makeGen.cpp program with the cppFiles, include statements and directory argument
	./makeG $cppFiles $includes $1

	# clean up the cpp program
	rm makeG

	# move the makefile into the given directory
	mv makefile $1/

	# run the make command and back out
	cd $1
	make
	cd $(pwd)
    else
	echo "No .cpp files found in directory"
	rm makeG
	exit 0
    fi
fi
