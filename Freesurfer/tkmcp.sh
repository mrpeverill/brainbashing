#This script just calls tkmedit with the arguments I like to use to edit control points
#By Matt Peverill - 10/23/2013 mrpeverill@gmail.com
#This script is deprecated - fsedit.sh is better

if [[ -z "$1" ]]; then
    echo "Please specify a subject number. eg to edit control points for subj 1097 in the current folder:"
    echo "tkmcp.sh 1097"
    exit
fi

tkmedit $1 brainmask.mgz -aux T1.mgz -surfs -aparc+aseg
