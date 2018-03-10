#!/bin/bash
#This is a script that makes sure there is an event file for each contrast in (subj)/contrasts/ . You'll probably need to edit the marked line specifying what the search string is for the contrast files.
red='\e[31m'
green='\e[92m'

shopt -s nullglob

for dir in 1* 0* 2* 3*
#for dir in 1005
do
    for file in $dir/contrasts/contrasts_run?.txt
    do
	events=( `awk '{print $3}' < $file | tr "," " " | tr "\n" " "` )
	good=1
	for event in ${events[@]}; do
	    if [ ! -e $dir/eventfiles/Run?/$event.txt ]; then
		echo "$dir/eventfiles/$event.txt not found from $file"
		good=0
	    fi
	done
	if [ $good -eq 0 ]; then
	    echo -e "${red}Problems found with $file"
	    tput sgr0
	else
	    echo -e "${green}$file tested good"
	    tput sgr0
	fi
    done
done
