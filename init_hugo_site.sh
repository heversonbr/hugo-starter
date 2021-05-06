#!/bin/bash

#confirm to continue function
function confirm_to_continue() {
    read -p "Continue (y/n)?" -n 1 -r
    echo  " "
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo "Aborting.."
        exit 1;
    fi
}

# check number of arguments
if [ $# -eq 0 ]; then
    echo "No arguments informed!"
    echo "Inform exactly: <new site name> and <link for template> of the desired template"
    exit 0;
elif [ $# -eq 1 ] || [ $# -gt 2 ]; then
    echo "Wrong number of arguments! [expecting 2]"
    echo "Inform exactly: <new site name> and <link for template> of the desired template"
    exit 0;
fi

NEW_SITE=$1
TEMPLATE_LINK=$2
echo "------------------------------------------------------------------------"
echo "Got site name: [$NEW_SITE]"
echo "Got template link: [$TEMPLATE_LINK]"
THEME_NAME=`echo $TEMPLATE_LINK | rev | cut -d'/' -f 1 | rev | cut -d'.' -f 1`
echo "Is [$THEME_NAME] the theme name?"
echo "------------------------------------------------------------------------"
confirm_to_continue
echo "------------------------------------------------------------------------"
echo "generating new site [$NEW_SITE]"
hugo new site $NEW_SITE
echo "------------------------------------------------------------------------"
echo "Check output and confirm if the site dir structure is correctly created!"
echo "Checking if git is installed"
git --version 
echo "Got a version?"
echo "------------------------------------------------------------------------"
confirm_to_continue
echo "------------------------------------------------------------------------"
echo "cd $NEW_SITE"
cd $NEW_SITE
echo "current dir: `pwd`" 

echo "git init"
git init 

echo "git submodule add $TEMPLATE_LINK themes/$THEME_NAME"
git submodule add $TEMPLATE_LINK "themes/$THEME_NAME"

echo "cd themes/$THEME_NAME"
cd themes/$THEME_NAME
echo "current dir: `pwd`" 

echo "cp -rf * ../../"
cp -rf * ../../

echo "cd ../../"
cd ../../
echo "current dir: `pwd`" 

echo "cp exampleSite/config.toml ."
cp exampleSite/config.toml .

echo "cp -Rf exampleSite/content ."
cp -Rf exampleSite/content .

echo "Done"
echo "------------------------------------------------------------------------"
echo "start hugo server? "
confirm_to_continue
hugo server -D
