#!/bin/bash
#This prints the beginning and end of all crash files matched by the argument. Eg:
#crashtail.sh crash-20130924* would match all files crash-20130924*.npz
#9/24/2013 by Matthew Peverill mrpeverill@gmail.com
array=(`ls crash-$@`)

echo -e "\e[00;35mListing all files matching ls crash-$@"

for files in ${array[@]}; do
    echo -e "\e[00;35m###  $files (400 characters of first and last 5 lines) :\e[00m"
    crashout=$(nipype_display_crash $files)
    echo $crashout | head | cut -c 1-400
    echo "
...
"
    echo "$crashout" | tail | cut -c 1-400
done
