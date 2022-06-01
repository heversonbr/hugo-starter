#!/bin/bash

# OBS: this script is used to transfer the content in $SOURCE_CONTENT_PATH to 
# the root directory of nginx (i.e., $DESTINATION_NGINX_ROOT).
# The folder $SOURCE_CONTENT_PATH at nginx host contains the same content of 
#  the ./$HUGO_SITE_NAME/public/ directory. Which is the directory where the hugo website is build, 
# using the ./build_site.sh script (or just hugo -D command).
# In order to transfer the content of the ./$HUGO_SITE_NAME/public/* folder to $SOURCE_CONTENT_PATH in the nginx host, 
# use the script ../sync_rasp2.sh or ../sync_rasp3.sh. 

source .env

# confirmation function to avoid undesirable overwrite! 
function confirm_to_execute() {
    while(true); do 
        read -p "Execute step (y/n/a)?" -n 1 -r
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

# rsync content from the remote content directory and the nginx root directory
echo "-------------------------------------------------------------------------------" 
CMD="rsync -avh --stats $PROD_BASE_SOURCE_CONTENT $PROD_DESTINATION_NGINX_ROOT"
echo "[RUN]=> $CMD" 
echo "-------------------------------------------------------------------------------"
confirm_to_execute
if [ "$?" == "0" ]; then
    eval "$CMD"
fi 
echo "-------------------------------------------------------------------------------"
echo "Done !!!" 
