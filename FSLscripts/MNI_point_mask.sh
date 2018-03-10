#!/bin/bash
#This is a script to generate a 5mm radius sphere mask around a given MNI coordinate. It handles xyz transformation for you. It's not really very fault tolerant and may do weird things if you use it wrong, so tread carefully and maybe don't use this a lot if you're not me. -Matt Peverill 5/10/2016
echo "Building mask based on point $1 $2 $3"
#coordinates of the MNI origin from https://www.nitrc.org/frs/?group_id=477
ox=45
oy=63
oz=36

nx=$(($ox-$1/2))
ny=$(($2/2+$oy))
nz=$(($3/2+$oz))
echo "MNI coord is $nx $ny $nz"
coordarg="$nx 1 $ny 1 $nz 1 0 1"
fslmaths /mnt/stressdevlab/SAS/standard_images/MNI152_T1_2mm_brain.nii.gz -mul 0 -add 1 -roi $coordarg $4-point -odt float
fslmaths $4-point -kernel sphere 5 -fmean $4-mask -odt float
