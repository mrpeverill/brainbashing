#!/bin/bash

#Reads DICOM files' metadata and sorts them into a directory structure reflecting their series descriptions and appends each file's series number to its name as a suffix. WARNING: This WILL move your files around a lot and you should use it with caution. It would be helpful to add a simulate option at some point. It requires mri_probedicom to be in your path.

#Author: Warren Winter

#Date: 07/12/2012
#Verson 2 revision by Matthew Peverill 
# * Cleaned up some uneccesary find commands which slowed the program down.
# * Made it so the program involves less copying
# * Added mosix support instead of using gnome-terminal to fork processes.
#Date: 08/19/2013
#Contact: mrpeverill@gmail.com

##############################################
#Config:
#This variable is for listing some sort of grid engine process. It's not strictly necessary.
qcommand=''
#qcommand='mosbatch -q'

##############################################
#Let's check and make sure mri_probedicom is installed
type mri_probedicom || { echo >&2 "mri_probedicom is required and not installed/not in path. Aborting."; exit 1; }

#This is the function that does all the work
function org_dicoms() {
		subj=$1
		subjorgd="./${subj}/${subj}_organized"
		for line in `find ./${subj} -path ${subjorgd} -prune -o -type f -print`; do
		    if [ -s $line ]
		    then
			seriesnumber=$(mri_probedicom --i $line --t 20 11 2> /dev/null)
			if [ $? -eq 1 ]
			then
			    echo "mri_probedicom failed for $line"
			else
			    seriesdescription=$(mri_probedicom --i $line --t 8 103E)
			    imagenumber=$(mri_probedicom --i $line --t 20 13)
			    newdirectory=$(echo "${seriesnumber}_${seriesdescription}" | sed -e "s/ //g")
			    oldname=$(basename $line .dcm)
			    newfile=$(echo "${oldname}-${imagenumber}.dcm" | sed -e "s/ //g")
			    mkdir -pv ./${subjorgd}/${newdirectory}    
			    mv -v $line ./${subjorgd}/${newdirectory}/${newfile}
			fi
		    else
			echo "$line does not exist"
		    fi
		done
		find ./${subj} -type d -empty -exec rmdir -v '{}' \;
}

export -f org_dicoms
##############################################

#Get Subjects List
if [ $# -eq 0 ]; then
    echo "List the subjects' subject IDs, separated by spaces (you could also list them as arguments to the command):"
    read subjsinput
    subjects=( "$subjsinput" )
else
    subjects=( "$@" )
fi

#If we can't find one of these subjects we should just call the whole thing off.
shouldexit=0
for s in ${subjects[@]}
do
    if [ ! -d "$s" ]; then
	echo "No directory found for ${s}; exiting"
	shouldexit=1
    fi
done

if [[ $shouldexit -eq 1 ]]
then
    exit
fi


#Here's where we call the above
for s in ${subjects[@]}
do
    echo "Organizing ${s}'s DICOMs into folders denoted by their scans of origin"
    eval "$qcommand org_dicoms $s 2>&1 > $s/organizedcm.log &"
done

wait


