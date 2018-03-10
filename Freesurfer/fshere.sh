#!/bin/bash
#fshere.sh v1 - MRP 10/3/2014 mrpeverill@gmail.com
#This script just sets Freesurfer's SUBJECTS_DIR directory to the current folder. Ordinarily bash scripts run in a subshell, so changes to env variables set in the script won't carry over to your session. So you have to run this script as:
#source fshere.sh OR
#. fshere.sh
#This script will detect if you do it right and yell at you if you don't.
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; 
   then
   export SUBJECTS_DIR=`pwd`
   echo -e "FS SUBJECTS_DIR is $SUBJECTS_DIR"
   else	
   echo -e "\e[31mSUBJECTS_DIR not set!\e[39m"
   echo "Because this sets an environment variable, you have to run it with a dot, like this:"
   echo ". fshere.sh"
fi
