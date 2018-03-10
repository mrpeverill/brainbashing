#!/bin/bash
#This erases files which contain only zero so they will not cause FSL to crash. We use it, for example, so that subjects who have empty white matter noise regressors don't break the analysis.
out=$(awk '{sum+=$1} END {print sum}' $1)
if [[ $out = 0 ]]; then
    echo "$1 contains only zeroes. Clearing file..."
    sed -iorig 's/0/ /' $1 
else
    echo "$1 totals $out"
fi
