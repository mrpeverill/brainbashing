#!/bin/bash
#This script should be run in sink_dir. It will look through all the (subj)/preproc folders and return a tab delimeted list of:
#(subj)	(run)	(count of artifacts that run)	(artifacts slice #)	
#Authored Matt Peverill 9/3/2013 - mrpeverill@gmail.com

trim() {
    local var=$@
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

#you need this line to not count empty sets:
shopt -s nullglob

echo -e "subj\trun\tartifacts\tcount"
for i in 0* 1* 2* ; do
    subj="`basename $i`"
    runs=""
    for l in $i/preproc/art/art.*.txt ; do
	artifacts="`cat $l`"
	artifacts=`trim $artifacts`
#    echo $artifacts
	count="`echo $artifacts | wc -w`"
#    echo "count = $count"
#    echo $artifacts
	run="`basename $l | sed -re 's|art.fsl_(.*)_outliers.txt|\1|'`"
#eg: art.fsl_1_1shapest_outliers.txt

#    echo $subj
#    echo $artifacts
#    echo $count
	echo -e "$subj\t$run\t$count\t$artifacts"
    done

done

#cat /net/rc-fs-nfs/ifs/data/Shares/DMC-Sheridan2/projects/SAS/BIPS_WM/sink_dir/1175/preproc/art/art.fsl_WM2st_outliers.txt | tr "\n" ","
