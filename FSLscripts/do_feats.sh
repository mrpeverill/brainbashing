#!/bin/bash
#Just runs all the feats specified through qsub. -t runs in test mode. Useful to run a bunch of feats at once (could be easily modified to use another grid engine or just run in parallel)

if [ $1 == "-t" ]; then
    for i in $@; do
	echo "qsub -cwd -V -b y /usr/share/fsl/5.0/bin/feat $i"
    done
else
    set -x
    for i in $@; do
	qsub -cwd -V -b y /usr/share/fsl/5.0/bin/feat $i
    done
fi
