#!/bin/sh

g++ makeGen.cpp -o makeG

if [ ! $1 ] ; then
    echo "Did not specify directory argument: ./makeGen [Directory Name]"
    rm makeG
    exit 0
else
    cppFiles=$(ls -a $1 | grep .cpp)
    hFiles=$(ls -a $1 | grep .h)
fi

includes=$(grep -i "#include" $1/*.cpp | sed 's/.*>//g' | sed 's/#include//g' | sed 's/.*\///g' | sed 's/\"//g' | sed 's/: /:/g')

./makeG $cppFiles $includes $1

rm makeG

mv makefile $1/

cd $1
make
cd $(pwd)
