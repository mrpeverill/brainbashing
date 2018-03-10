#!/bin/bash
#Check FSL nuisance regressor files for some problems.
for f in $@; do
    awk -v file="$f" '{for (i=1;i<=NF;i++) sum[i]+=$i;}; END{for (i in sum) if (sum[i] == 0) print "WARNING: column "i" in file "file" is " sum[i];}' $f
done

