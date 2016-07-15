#!/bin/sh
#
# Generates C++ Makefiles

# Global Variables
# name of the program
MKG="mkg"

# name of the directory MakeGen builds from
# default value = current directory
DIR="."

# name of the binary the Makefile will create
# default value = a.out
EXENAME="a.out"

# checks for command line argument overrides
while [ $# -gt 0 ]; do
  case "$1" in
    # override directory MakeGen builds from
    --dir)
      DIR=$2
      shift
      ;;
    # override the name of the binary the Makefile creates
    --exe)
      EXENAME=$2
      shift
      ;;
    # end of arguments flag
    --)
      shift
      break
      ;;
    # catch all that prompts usage
    -*)
      echo >&2 \
      "usage: $MKG [--dir directory] [--exe exename]"
      exit 1
      ;;
  esac
  shift
done

# converts all files in directory that contain DOS line breaks
# redirects the output to /dev/null
dos2unix -ic ${DIR}*.cpp &> /dev/null | xargs dos2unix &> /dev/null

#######################################
# Validates incoming arguments
# Globals:
#   MKG
#   DIR
#   EXENAME
# Arguments:
#   None
# Returns:
#   0
#   1
#######################################
validate_args ()
{
  # if directory doesn't exist
  if [[ ! -d "$PWD/$DIR" ]]; then
    echo "$MKG: $DIR: No such directory"
    return 1
  else
    return 0
  fi
}

#######################################
# Returns all of the dependencies
# Globals:
#   DIR
# Arguments:
#   None
# Returns:
#######################################
get_dependencies ()
{
  CPP_FILES="$(ls $DIR/* | grep .cpp)"
  H_FILES="$(ls $DIR/* | grep .h)"
  FILES="$CPP_FILES
        $H_FILES"

  INCLUDES="$(grep "#include" $FILES \
            | sed 's/[[:space:]]\+//g' \
            | sed 's/.*>//g' \
            | sed 's/.*\///g' \
            | sed 's/#include//g' \
            | sed 's/:.* /:/g' \
            | sed 's/"//g' \
            | sed 's/.cpp:/:/g' \
            | sed 's/.h:/:/g' \
            | sort | uniq)"
  echo $INCLUDES
}

if validate_args; then
 DEPENDENCIES=$(get_dependencies)

g++ mkg.cpp -o MakeG
echo "$(./MakeG $DEPENDENCIES)"
else
  exit 1
fi
