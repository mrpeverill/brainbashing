#!/bin/bash

# Concatenates crash file output into one text file, grouped by the date of the files' timestamps.  Must have nipype's bin folder in your $PATH (automatically done when using the bips alias in the .bashrc file made in May 2013).

# Warren Winter

read -p "Enter in YYYYMMDD format the date whose crash files you want to display: " yyyymmdd
ls crash-${yyyymmdd}* >> crashlist.txt
while read crashfile; do
	nipype_display_crash $crashfile >> crashlogs_${yyyymmdd}.txt
done < crashlist.txt
rm crashlist.txt
