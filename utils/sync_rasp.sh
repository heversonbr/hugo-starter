#!/bin/bash
# NOTE: this script assumes that you have a .config file in your .ssh directory
#       ready to allow rsync remotely access to the destination host, via ssh. 

source .env

# confirmation function to avoid undesirable overwrite! 
function confirm_to_execute() {

    while(true); do 
        read -p "Execute next step (y/n/a)?" -n 1 -r
        # -n nchars:  Stop reading after an integer number nchars characters are read, if the line delimiter has not been reached.
        # -r 	   :  Use "raw input". Specifically, this option causes read to interpret backslashes literally, rather than interpreting them as escape characters.
        echo " "
        case $REPLY in
            [Yy])
                return 0;
                break;;
            [Nn])
                #echo "N"
                return 1;
                break;;
            [Aa]) echo "Aborting..."
                exit 1;;
            *) echo "Invalid choice"
        esac
    done
}

# check arguments
function check_args(){

    NUMB_ARGS=$1
    ARG_VALUE=$2
    
    if [ $NUMB_ARGS -eq 0 ]; then
        echo "-------------------------------------------------------------------------------"
        echo "No arguments informed! Using default project name: [$HUGO_SITE_NAME]"
    elif [ $NUMB_ARGS -eq 1 ]; then
        echo "-------------------------------------------------------------------------------"
        HUGO_SITE_NAME=$ARG_VALUE
        echo "Using site project name: [$HUGO_SITE_NAME]"
    elif [ $NUMB_ARGS -gt 1 ]; then
        echo "-------------------------------------------------------------------------------"
        echo "Wrong number of arguments! [expecting 1 argument only]"
        exit 0;
    fi

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

# check arguments 
check_args $# $1

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

SRC_PATH="$DIRNAME/$SRC_CONTENT_PATH"


echo "**************************************************"
echo "Rsync local repository and rasp $HOST"
echo "**************************************************"
# Preparing Rsyn
echo "SRC_PATH: $SRC_PATH"
echo "REMOTE_PATH: $REMOTE_PATH"
echo "EXCLUDE_PROD_FILES: $EXCLUDE_PROD_FILES"

# rsync content in the <project_name>/public directory
echo "-------------------------------------------------------------------------------" 
CMD="rsync -avh $SRC_PATH $USER@$HOST:$REMOTE_PATH --exclude=$EXCLUDE_PROD_FILES"
echo "[RUN]=> $CMD" 
echo "-------------------------------------------------------------------------------"
confirm_to_execute
if [ "$?" == "0" ]; then
    eval "$CMD"
fi 
echo "-------------------------------------------------------------------------------"
echo "Done !!!" 