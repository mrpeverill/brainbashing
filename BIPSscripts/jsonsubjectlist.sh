#!/bin/bash
#This searches all BIPS style json files in the current directory for anything resembling a subject number starting with 1 and prints a comma delimited list
echo -n ","
for i in *json; do
    echo -ne `basename $i .json` ","
done;

for s in `egrep -o ^1*[0-9]{3}[WM]* $1`; do
    echo ""
    echo -n $s ","
    for i in *json; do
	echo -ne `grep -c \"$s\" $i` ","; 
    done;
done;
