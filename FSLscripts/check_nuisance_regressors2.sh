#!/bin/bash
#Check FSL nuisance regressor files for common problems
for f in $@; do
    awk -v file="$f" '{for (i=1;i<=NF;i++) sum[i]+=$i;}; END{for (i in sum) if (sum[i] == 0) print i;}' $f
done

