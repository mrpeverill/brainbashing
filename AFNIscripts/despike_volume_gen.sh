#!/bin/bash
#MRP 9/30/2015
#Built to replace despike make code that is parallel intolerant due to AFNI's rigidity around filenames. Takes volume to despike as first argument, afnipath as second argument, and the output file prefix as a third argument.
#output filenames are:
#(prefix)_despike.nii.gz
#(prefix)_spikiness.nii.gz

fn=`basename $1`
pd=`dirname $1`
wd="${pd}/${fn}_despike_temp"
target=$wd/$fn
afnipath=$2

if [ -e $3_despike.nii.gz ]; then
    echo "WHOOPS: $3_despike.nii.gz exists already and afni can't deal - you need to delete these first!"
fi

if [ -e $3_spikiness.nii.gz ]; then
    echo "WHOOPS: $3_despike.nii.gz exists already and afni can't deal - you need to delete these first!"
fi

if [ -d $wd ]; then
    echo "WD exists already, deleting contents"
    rm -v $wd/*
fi

echo "Despiking the functional data with AFNI" && \
mkdir -pv $wd
ln -sv ../$fn $target
cd $wd
#pwd
#echo $afnipath
$afnipath/3dDespike -ssave spikiness -q $fn
$afnipath/3dAFNItoNIFTI despike+orig.BRIK
$afnipath/3dAFNItoNIFTI spikiness+orig.BRIK
mv -v despike.nii ../$3_despike.nii
mv -v spikiness.nii ../$3_spikiness.nii
cd ..
gzip $3_despike.nii
gzip $3_spikiness.nii

#Old make code:
# echo "Despiking the functional data with AFNI" && \
#     rm -f `dirname EMO/EMO1_bet.nii.gz`/despike.nii.gz ;\
# rm -f `dirname EMO/EMO1_bet.nii.gz`/spikiness.nii.gz ;\
# rm `dirname EMO/EMO1_bet.nii.gz`/`basename EMO/EMO1_bet.nii.gz _bet.nii.gz`_despike.nii.gz ;\
# rm `dirname EMO/EMO1_bet.nii.gz`/`basename EMO/EMO1_bet.nii.gz _bet.nii.gz`_spikiness.nii.gz ;\
# /usr/lib/afni/bin//3dDespike -ssave spikiness -q EMO/EMO1_bet.nii.gz && \
#     /usr/lib/afni/bin//3dAFNItoNIFTI despike+orig.BRIK && \
#     /usr/lib/afni/bin//3dAFNItoNIFTI spikiness+orig.BRIK && \
#     mv despike.nii `dirname EMO/EMO1_bet.nii.gz`/`basename EMO/EMO1_bet.nii.gz _bet.nii.gz`_despike.nii && \
#     mv spikiness.nii `dirname EMO/EMO1_bet.nii.gz`/`basename EMO/EMO1_bet.nii.gz _bet.nii.gz`_spikiness.nii && \
#     gzip `dirname EMO/EMO1_bet.nii.gz`/`basename EMO/EMO1_bet.nii.gz _bet.nii.gz`_despike.nii && \
#     gzip `dirname EMO/EMO1_bet.nii.gz`/`basename EMO/EMO1_bet.nii.gz _bet.nii.gz`_spikiness.nii && \
#     rm -f despike+orig* && \
#     rm -f spikiness+orig*

