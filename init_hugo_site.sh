#!/bin/bash
# Author: Heverson B. Ribeiro
# Script that helps to create a new site based on HUGO. 

function confirm_to_execute() {

    while(true); do 
        read -p "Execute next step (y/n/a)?" -n 1 -r
        # -n nchars:  Stop reading after an integer number nchars characters are read, if the line delimiter has not been reached.
        # -r 	   :  Use "raw input". Specifically, this option causes read to interpret backslashes literally, rather than interpreting them as escape characters.
        echo " "
        #echo  $REPLY
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

function usage(){
    echo "-------------------------------------------------------------------------------"
    echo "USAGE:  Inform exactly:"
    echo " "
    echo "./init_new_hugo_site.sh <new site name>  <link of desired template>"
    echo "-------------------------------------------------------------------------------"
}

# check number of arguments
if [ $# -eq 0 ]; then
    echo "-------------------------------------------------------------------------------"
    echo "No arguments informed!"
    usage
    exit 0;  
elif [ $# -eq 1 ] || [ $# -gt 2 ]; then
    echo "-------------------------------------------------------------------------------"
    echo "Wrong number of arguments! [expecting 2]"
    usage
    exit 0;
fi

NEW_SITE=$1
TEMPLATE_LINK=$2

echo "*************************************************************************"
echo "              START - building a new HUGO site from theme"
echo "*************************************************************************"
echo "[INFO] Got site name:  $NEW_SITE"
echo "[INFO] Got template link:  $TEMPLATE_LINK"
THEME_NAME=`echo $TEMPLATE_LINK | rev | cut -d'/' -f 1 | rev | cut -d'.' -f 1`
echo "[INFO] I have this theme name from the link : [$THEME_NAME] ?"
echo "------------------------------------------------------------------------"
confirm_to_execute
echo "------------------------------------------------------------------------"
echo "[INFO] Generating New Hugo Site [$NEW_SITE]"
echo "[CMD] : hugo new site $NEW_SITE"
confirm_to_execute
hugo new site $NEW_SITE
echo "------------------------------------------------------------------------"
echo "[INFO] Check output and confirm if the site dir structure is correctly created!"
echo "[INFO] Checking if git is installed"
git --version 
echo "[INFO] Got a version? if yes, ready to go!"
echo "------------------------------------------------------------------------"
echo "[INFO] Preparing to install theme."
echo "[INFO] Note that most of the themes follow the same install algorithm ."
echo "[INFO] cd themes"
echo "[INFO] git init"
echo "[INFO] git submodule add <THEME_TEMPLATE_LINK> <themes/THEME_NAME> "
echo "------------------------------------------------------------------------"
echo "[INFO] Check the instructions in the theme's website to be sure that the"
echo "[INFO] theme you've chosen follows the same procedure before continuing."
echo "------------------------------------------------------------------------"
confirm_to_execute
if [ "$?" != "0" ]; then
    exit 1;
fi

echo "[INFO] changing dir to $NEW_SITE"
cd $NEW_SITE
echo "[INFO] current dir: `pwd`" 
echo "------------------------------------------------------------------------"
echo "[CMD] : git init"
confirm_to_execute
if [ "$?" == "0" ]; then
    git init
fi 
echo "------------------------------------------------------------------------"
echo "[CMD] : git submodule add $TEMPLATE_LINK themes/$THEME_NAME"
confirm_to_execute
if [ "$?" == "0" ]; then
    git submodule add $TEMPLATE_LINK "themes/$THEME_NAME"
fi
echo "------------------------------------------------------------------------"
echo "[INFO] theme was added as a submodule " 
echo "------------------------------------------------------------------------"
#echo "[INFO] I'll replace new site default directories with theme content"
#echo "[INFO] Current Dir: `pwd`" 
#echo "[CMD] cp -rf themes/$THEME_NAME/* . "
#confirm_to_execute
#if [ "$?" == "0" ]; then
#    cp -rf themes/$THEME_NAME/* . 
#fi
echo "------------------------------------------------------------------------"
echo "[INFO] Current Dir: `pwd`" 
echo "[INFO] Copy config.toml from exampleSite dir to root dir?"
echo "theme : $THEME_NAME" 
echo "[CMD] : cp themes/$THEME_NAME/exampleSite/config.toml ."
confirm_to_execute
if [ "$?" == "0" ]; then
    cp themes/$THEME_NAME/exampleSite/config.toml .
else 
    echo "[WRN] Not running CMD: cp themes/$THEME_NAME/exampleSite/config.toml ."
fi 
echo "------------------------------------------------------------------------"
echo "[INFO] Current Dir: `pwd`" 
echo "[INFO] Copy content from exampleSite dir to root dir? (not required)"
echo "[CMD] : cp -Rf themes/$THEME_NAME/exampleSite/content ."
confirm_to_execute
if [ "$?" == "0" ]; then
    cp -Rf themes/$THEME_NAME/exampleSite/content .
else 
    echo "[WRN] Not running CMD: cp -Rf themes/$THEME_NAME/exampleSite/content ."
fi 
echo "------------------------------------------------------------------------"
echo "[INFO] Current Dir: `pwd`" 
echo "[INFO] Removing redundant folders (if previously copied) ?"
echo "[CMD] : rm -Rf themes/$THEME_NAME"
confirm_to_execute
if [ "$?" == "0" ]; then
    rm -Rf themes/$THEME_NAME
else 
    echo "[WRN] Not running CMD: rm -Rf themes/$THEME_NAME"
fi 

echo "------------------------------------------------------------------------"
echo "[INFO] Config Done!"
echo "------------------------------------------------------------------------"
# copy 'utils' scripts.
cp -p ../utils/*.sh . 
cp -p ../utils/base_env_file ./.env

echo "[INFO] Current Dir: `pwd`" 
echo "Start hugo server? "
echo "[CMD] : hugo server -D"
confirm_to_execute
if [ "$?" == "0" ]; then
    hugo server -D
else 
    echo "[WRN] Not running CMD: hugo server -D"
fi 
echo "---------------------------------- END ------------------------------------"