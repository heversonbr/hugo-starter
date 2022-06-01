#!/bin/bash
# This script just createss a bkp copy of the current site. 

# loads ENV variables from the .env file 
source .env

# confirmation function to avoid undesirable overwrite 
function confirm_to_proceed() {
    # returns 0 if answer is 'yes'
    # returns 1 if answer is 'no'
    # exits program if 'abort' is selected
    while(true); do 
        read -p "Execute step (y/n/a)?" -n 1 -r
        # -n <nchar>: Stop reading after 'nchar' integer number of characters are read, 
        #                  if the line delimiter has not been reached.
        # -r 	   : Use "raw input". Specifically, this option causes read to interpret 
        #                  backslashes literally, rather than interpreting them as escape characters.
        echo " "
        case $REPLY in
            [Yy])
                return 0;
                break;;
            [Nn])
                return 1;
                break;;
            [Aa]) echo "Aborting..."
                exit 1;;
            *) echo "Invalid choice"
        esac
    done
}
# -----------------------------------------------------

# function to check arguments 
function check_arguments() {
    NUMB_ARGS=$1
    ARG_VALUE=$2
    echo "Checking arguments..."
    # check arguments 
    if [ $NUMB_ARGS -eq 0 ]; then
        echo "No arguments informed! Using PROJECT NAME from .env file: [$HUGO_SITE_NAME]"
        echo "Use default project name => [$HUGO_SITE_NAME] ?"
        confirm_to_proceed
        if [ "$?" == "1" ]; then
            echo "aborting execution."
            exit 1;
        fi 

    elif [ $NUMB_ARGS -eq 1 ]; then
        echo " Received arguments: [$ARG_VALUE]"
        echo "Use project name => [$ARG_VALUE] ?"
        confirm_to_proceed
        if [ "$?" == "1" ]; then
            echo "aborting execution."
            exit 1;
        fi 
        HUGO_SITE_NAME=$ARG_VALUE
        echo "Using project name: [$HUGO_SITE_NAME] for this backup"
    elif [ $NUMB_ARGS -gt 1 ]; then
        echo "Wrong number of arguments! [expecting only 1 argument=> SITE_PROJECT_NAME]"
        exit 0;
    fi

}

# function to check destination directory
function check_destination() {
    # check if destination directory already exists (avoid merge/replace)
    if [ -d "$DIRNAME/$BKP_DESTINATION_DIR" ]; then
        echo "Directory [$DIRNAME/$BKP_DESTINATION_DIR] already exists!!!"
        echo "Do you want to replace it?"
        confirm_to_proceed
        if [ "$?" == "1" ]; then
            echo "Aborting execution: destination dir exists!"
            exit 1;
        fi
        echo "Cleaning destination directory..."
        rm -Rf $DIRNAME/$BKP_DESTINATION_DIR
    fi
}

# function to create list of files to exclude 
function create_exclude_file_list() {
    # Create 'exclude file' for rsync
    # NOTE: Bash has IFS as a reserved internal variable to recognize word boundaries. Hence, we would first need to assign IFS as a recognizable character as per the requirement to do the split. By default, the variable IFS is set to whitespace. Next is to read the string containing the words which needs to be split by a command read as read -ra<array_name><<<“$str”. “-r” is for not allowing backslash to act as backspace character, and in “-a<array_name>” we may use any array name as per convenience in place of <array_name> and this commands ensures that the words are assigned sequentially to the array, starting from index 0 (zero). But be very careful to assign the IFS variable as whitespace after the use of IFS is done within the code.
    #       IFS='<symbol_for_separation>'
    #       read -ra<array_name><<<"$str"
    echo "Creating EXCLUDE file for RSYNC"
    > bkp_exclude_files.dat
    IFS=','  # IFS delimiter 
    read -raoutputSplitArray<<< "$BKP_EXCLUDE_FILES"
    # outputSplitArray is the array where the split words will be put into
    for word in "${outputSplitArray[@]}"; do
        echo "Adding  $word"
        echo $word | xargs >> bkp_exclude_files.dat
    done
    echo "Done."
}

# print variables used by rsync
function show_variables(){
    echo "--------------------------- Variables -----------------------------------------"
    echo "PROJECT NAME: $HUGO_SITE_NAME"
    echo "WORKING DIR: $WORKING_DIR"
    echo "DIR NAME: $DIRNAME"
    echo "BASE NAME: $BASEDIR"
    echo "-------------------------------------------------------------------------------"
}

# -----------------------------------------------------
echo "********************************************************************************"
echo "Creating Backup of hugo site [$HUGO_SITE_NAME] with Rsync"
echo "********************************************************************************"

## check arguments 
check_arguments $# $1

# Paths and directories
WORKING_DIR=`pwd`
DIRNAME=`dirname $WORKING_DIR`
BASEDIR=`basename $WORKING_DIR`

show_variables

# check if 'project name' and current 'working-dir base-name' are the same
if [ "$HUGO_SITE_NAME" != "$BASEDIR" ]; then
    echo "PROJECT NAME and WORKING DIR are not the same!"
    exit 0;
fi
# check if directory with project name exists
if [ ! -d "$DIRNAME/$HUGO_SITE_NAME" ]; then
    echo "Directory [$DIRNAME/$HUGO_SITE_NAME] with hugo site project does not exist!!!"
    exit 0;
fi

BKP_SRC_PATH=$DIRNAME/$HUGO_SITE_NAME
BKP_DESTINATION_PATH=$DIRNAME/$BKP_DESTINATION_DIR

# Preparing RSYNC 
echo "BKP_SRC_PATH: $BKP_SRC_PATH"
echo "BKP_DESTINATION_DIR: $BKP_DESTINATION_PATH"
echo "BKP_EXCLUDE_FILES=> $BKP_EXCLUDE_FILES"
echo "-------------------------------------------------------------------------------"
# check if destination directory already exists (avoid merge/replace)
check_destination
# create list of files to be excluded by rsync
create_exclude_file_list

echo "-------------------------------------------------------------------------------"
## Running rsync to backup the directory <project_name> to the destination
CMD="rsync -avh $BKP_SRC_PATH $BKP_DESTINATION_PATH --exclude-from 'bkp_exclude_files.dat'"
echo "[RUNNING]:"
echo "=> $CMD"
echo "-------------------------------------------------------------------------------"
# Executing the command in the variable CMD
# REF: remind =>  https://unix.stackexchange.com/questions/444946/how-can-we-run-a-command-stored-in-a-variable
eval "$CMD"

# cleanup: exclude tmp file
rm bkp_exclude_files.dat