#!/bin/bash
: <<EOF
fslsum.sh - 6/2016 by Matthew Peverill mrpeverill@gmail.com
This is a very simple script which takes an output volume as its first argument and an arbitrary number of additional volumes as additional arguments. It sums all the volumes and writes them to the output volume.

Error and safety checking is minimal - be careful.
########
EOF
purple="\e[35m"
std="\e[39m"

if [ -e $1 ]
then
    echo "ERROR: output volume exists! You need to delete $1 if you want to overwrite it"
    exit 1
fi

out=$1
echo -e "${purple}Creating output from first two inputs: #1-${2}, #2-${3} ${std}"
fslmaths $2 -add $3 $out
shift
shift
shift

while (($# >= 1))
do
    echo -e "${purple}Adding $1$std"
    fslmaths $out -add $1 $out
    shift
done
