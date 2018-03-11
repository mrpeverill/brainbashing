#!/bin/bash
#This script should be run in the bips sink directory. It will list all folders that start with 0-3 (subject folders) and try to detect what stage of bips processing has been completed for each one.
#The -i option wil list only incomplete subjects
#The -l option, followed by a number, will give you a list of subjects who have not completed a given stage. So show_bips_status.sh -l 3 will show everyone who doesn't have a qa report. This is given in a format ready to be copy pasted directly in to a json file
#Authored 9/24/2013 by Matt Peverill - mrpeverill@gmail.com
i=0
list=0
while getopts :il: opt; do
    case $opt in
	i)
	    i=1
	    ;;
	\?)
	    echo "Invalid option: $OPTARG" >&2
	    exit 1
	    ;;
	l)
	    list=1
	    listfield=$OPTARG
	    listsubjects=()
	    ;;
	:)
	    echo "Option- $OPTARG requires an argument." >&2
	    exit 1
	    ;;
	esac
done



pwd=`pwd`
if [ $list = 0 ]; then
    echo "report on bips status of subject folders in $pwd:
"
    echo "0	1	2	3	4	5	6	7	"
    echo "Subj	Convert	preproc	QA	firstl	fixedfx	snorm	fnorm	"
fi

for dir in 1* 0* 2* 3*
do
    line[0]=$dir
    complete=1
    if [ ! -e "${dir}" ]; then
	continue
    fi
#   testing convert
    ngz=("${dir}/"*.nii.gz)
    if [ -e "${ngz[0]}" ]; then
	line[1]=${#ngz[@]}
    else
	line[1]="_"
	complete=0
    fi
    #testing preproc
    if [ ! -e "${dir}/preproc" ]; then
	line[2]="_"
	complete=0
    else
	line[2]="X"
    fi
    #testing QA
    pdfs=("${dir}/"*.pdf)
    if [ ! -e "${pdfs[0]}" ]; then
	line[3]="(_)"
    else
	line[3]="(X)"
    fi
#   testing firstlevel
    if [ ! -e "${dir}/modelfit" ]; then
	line[4]="_"
	complete=0
    else
	line[4]="X"
    fi

#   testing fixedfx
    if [ ! -e "${dir}/fixedfx" ]; then
	line[5]="_"
	complete=0
    else
	line[5]="X"
    fi

#   testing structural_norm
    if [ ! -e "${dir}/smri" ]; then
	line[6]="_"
	line[7]="_"
	complete=0
    else
	line[6]="X"
	#testing functional_norm
	if [ ! -e "${dir}/smri/warped_image" ]; then
	    line[7]="_"
	    complete=0
	else
	    line[7]="X"
	fi
    fi

    if [[( $complete = 0 || $i == 0) && $list = 0 ]]; then
	for l in ${line[@]}; do
	    echo -n "$l	"
	done
	echo
    fi
#    echo ${list["$listfield"]}
#    echo ${line[5]}
    if [[ $list == 1 && (${line[$listfield]} = "_" || ${line[$listfield]} = "(_)") ]]; then
	listsubjects+=( "\"${line[0]}\"" )
    fi
    if [[ $list == 1 && $listfield = "a" && ${line[7]} = "X" ]]; then
	listsubjects+=( "\"${line[0]}\"" )
    fi
done

if [ $list = 1 ]; then
    separator=", " # e.g. constructing regex, pray it does not contain %s
    regex="$( printf "${separator}%s" "${listsubjects[@]}" )"
    regex="${regex:${#separator}}" # remove leading separator
    echo "${regex}"
fi
