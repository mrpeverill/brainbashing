#!/bin/bash
usage()
{
cat <<EOF
fsedit.sh By Matt Peverill - 10/23/2013 mrpeverill@gmail.com

This is designed as a wrapper for tkmedit. This is what it does:
* Checks for three common errors:
 1. Running the program outside of your fs subjects_dir
 2. subjects_dir is a 'raw' folder.
 3. The subject has changes more recent than the last recon-all (so might need it first)
 4. Subject folder does not exist
* Offers to copy over the 'raw' subject if needed. (not implemented yet)
* Runs tkmedit with common commands to edit control points (or white matter with the -wm option)
* Writes a log with the date, time, and username 

Usage: fsedit.sh (subj)
Alt: fsedit.sh -w (subj) for wm edits.
EOF
}

wm=''
while getopts ":hw" OPTION
do
    case $OPTION in
	h)
	    usage
	    exit 1
	    ;;
	w)
	    echo "Editing in white matter mode"
	    wm="in white matter mode"
	    ;;
	?)
	    usage
	    exit
	    ;;
    esac
done   
shift $(($OPTIND - 1))

#echo "wm is $wm"

if [[ -z "$1" ]]; then
    echo "Please specify a subject number. eg to edit control points for subj 1097 in the current folder:"
    echo "tkmcp.sh 1097"
    exit
fi

subject=$1
sfold="${SUBJECTS_DIR}/${subject}"

#Check if you're running from subjects_dir
if [[ $SUBJECTS_DIR != `pwd` ]]; then
    read -p "You're not running the script from \$SUBJECTS_DIR (${SUBJECTS_DIR}). tkmedit will open the subject from the subjects dir. Press any key to continue or Ctrl+c to exit."
fi

#Check if you're trying to edit a raw image
if [[ $SUBJECTS_DIR == *raw* ]]; then
    read -p "${SUBJECTS_DIR} looks like a folder for raw images. You should copy it before making edits. Press any key to continue or Ctrl+c to exit."
fi

if [ -e $SUBJECTS_DIR/$1/scripts/IsRunning.lh+rh ]; then
    read -p "WARNING: Recon-all is currently running on this subject. You should DEFINITELY not make any edits, but you can view the brain if you want. If this is an error you can delete 'scripts/IsRunning.lh+rh' to clear the hold condition. Press any key to continue or Ctrl+c to exit."
fi

if [ ! -e $SUBJECTS_DIR/$1 ]; then
    echo "Subject Directory Does not Exist in $SUBJECTS_DIR."
    exit 1
fi

writecheck="0"

if [[ -e $sfold/tmp/control.dat && ! -w $sfold/tmp/control.dat ]]; then
    echo  "You do not have permission to write control points for this subject."
    writecheck="1"
fi

if [ ! -w $sfold/mri/T1.mgz ] || [ ! -w $sfold/mri/wm.mgz ] || [ ! -w $sfold/mri/brainmask.mgz ]; then
    echo "You do not have permission to write to one or more brain volumes for this subject"
    writecheck="1"
fi

if [[ $writecheck -eq "1" ]]; then
    read -p "You will not be able to save changes. Press any key to continue or Ctrl+c to exit."
fi

#Check if you're editing before running recon-all
logfile=${sfold}/scripts/fsedit.log
if [ $logfile -nt ${sfold}/scripts/recon-all.log ]; then
    read -p "Edits have been made since the last time recon-all was run (they won't be reflected in the segmentation). Press any key to continue or Ctrl+c to exit."
fi


#starttime= `date`
#echo "fsedit session opened by $USER at $starttime"
md5brainmask="`md5sum ${sfold}/mri/brainmask.mgz`"
md5t1="`md5sum ${sfold}/mri/T1.mgz`"
md5wm="`md5sum ${sfold}/mri/wm.mgz`"
md5control="`md5sum ${sfold}/tmp/control.dat 2>/dev/null || echo 0`"  

mkdir -p $sfold/tmp
echo -e "\e[95mRunning tkmedit ${w}..."
if [[ $wm = '' ]]; then
    /usr/local/freesurfer/stable5_3/bin/tkmedit $subject brainmask.mgz -aux T1.mgz -surfs -aparc+aseg
    else
    /usr/local/freesurfer/stable5_3/bin/tkmedit $1 T1.mgz -aux wm.mgz -surfs -aparc+aseg -bc-main .53 12
fi
echo -e "tkmedit is finished.\e[39m"

changes=''
if [[ "`md5sum ${sfold}/mri/brainmask.mgz`" != $md5brainmask ]]; then changes+=' brainmask.mgz'; fi
if [[ "`md5sum ${sfold}/mri/T1.mgz`" != $md5t1 ]]; then changes+=' t1.mgz'; fi
if [[ "`md5sum ${sfold}/mri/wm.mgz`" != $md5wm ]]; then changes+=' wm.mgz'; fi
if [[ "`md5sum ${sfold}/tmp/control.dat 2>/dev/null || echo 0`" != $md5control ]]; then changes+=' control points'; fi

if [[ $changes != '' ]]; then
    enddate=`date`
    if [[ -e ${sfold}/tmp/control.dat ]]; then
	cps=`grep numpoints ${sfold}/tmp/control.dat | awk '{ print $2 }'`
    else
	cps='0'
    fi
    echo "${enddate}: $USER made changes to $changes with fsedit. There are $cps Control Points" | tee -a $logfile
fi

    
