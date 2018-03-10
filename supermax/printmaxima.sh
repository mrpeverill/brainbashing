#!/bin/bash
#This is a script for making cluster table that attempts to find local maxima within larger thresholded clusters. Work in progress for sure.
minthresh=2.2
maxthresh=4.1
thresh=$minthresh
interval=.1
output=""

#echo "x y z zs thresh"
while (( $(echo "$thresh < $maxthresh" | bc -l) )); do
    echo "["
    cluster -z $1 -t $thresh | tail -n +2 | awk -v thresh="$thresh" '{print "[" $4 "," $5 "," $6 "," $3 "," thresh "]"}'
    thresh=`echo "$thresh+$interval" | bc`
    echo "]"
done
