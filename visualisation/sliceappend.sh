#!/bin/bash

# sliceappend.sh v1 8/7/2015 - Matt Peverill mrpev@uw.edu
# This script takes two nifti file as inputs (typically images you are registering to one another) and makes slices of the outline of one image over the other on one row and the reverse on the next. It takes any number of slices you specify.
# It makes it's own temporary directory, so as long as you are not running two copies on the same set of images it should be able to run in parallel cleanly.


usage () { echo 'USAGE: sliceappend.sh -1 (first file to slice) -2 (second file to slice) -o (output png file) -s (for standard slices) 
OR specify manually: -x "x slices space separated" -y "y slices space separated" -z "z slices space separated"

You must specify at least one slice in each dimension
'; }

pwd=`pwd`

while getopts "1:2:o:sx:y:z:" opt; do
    case $opt in
	1)
	    ifile="$OPTARG"
	    echo "input one is $ifile"
	    ;;
	2)
	    ifile2="$OPTARG"
	    echo "input two is $ifile2"
	    ;;
	o)
	    ofile="$OPTARG"
	    echo "output file is $ofile"
	    ;;
	s)
	    stpar="0.35 0.45 0.55 0.65 "
	    echo "using standard slice parameters"
	    ;;
	x) xin=$OPTARG ;;
	y) yin=$OPTARG ;;
	z) zin=$OPTARG ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
    esac
done

if [ -z $ifile ] || [ ! -s $ifile ] || [ -z $ifile2 ] || [ ! -s $ifile2 ]
then
    echo
    echo "You did not specify two input files or input files not found!" >&2
    echo
    usage
    exit 1
fi

if [ -z $ofile ]
then
    echo
    echo "You did not specify an output file!" >&2
    echo
    usage
    exit 1
fi

if [ -z "$stpar" ] && ( [ -z "$xin" ] || [ -z "$yin" ] || [ -z "$zin" ] )
then
    echo
    echo "Please specify either -s (standard slices) or x, y, and z slice coordinates." >&2
    echo
    usage
    exit 1
fi

#This is a pretty janky way to sort, but it works
x=`echo "${stpar}${xin}" | tr " " "\n" | sort -g | tr "\n" " "`
y=`echo "${stpar}${yin}" | tr " " "\n" | sort -g | tr "\n" " "`
z=`echo "${stpar}${zin}" | tr " " "\n" | sort -g | tr "\n" " "`

echo "Getting slices:"
echo "x - $x"
echo "y - $y"
echo "z - $z"

dirname=`dirname $ofile`/`basename ${ifile}`X`basename ${ifile2}`.slices
mkdir -p $dirname/fwd
mkdir -p $dirname/rev

for i in $x ; do
    xstring="$xstring -x $i $dirname/x$i.png"
    xstring2="$xstring2 + $dirname/x$i.png"
done
#echo $xstring2

for i in $y ; do
    ystring="$ystring -y $i $dirname/y$i.png"
    ystring2="$ystring2 + $dirname/y$i.png"
done
#echo $ystring2

for i in $z ; do
    zstring="$zstring -z $i $dirname/z$i.png"
    zstring2="$zstring2 + $dirname/z$i.png"
done
#echo $zstring2

#These get generated with an extraneous plus, so we need to trim that:
xstring2=${xstring2:3}
ystring2=${ystring2:3}
zstring2=${zstring2:3}

c2="/usr/share/fsl/5.0/bin/slicer $ifile $ifile2 -s 2 $xstring $ystring $zstring"
c3="pngappend $xstring2 + $ystring2 + $zstring2 $dirname/int1.png"
c4="mv $dirname/*.png $dirname/fwd"
c5="/usr/share/fsl/5.0/bin/slicer $ifile2 $ifile -s 2 $xstring $ystring $zstring"
c6="pngappend $xstring2 + $ystring2 + $zstring2 $dirname/int2.png"
c7="mv $dirname/*.png $dirname/rev"
c8="pngappend $dirname/fwd/int1.png - $dirname/rev/int2.png $ofile"

for c in "$c1" "$c2" "$c3" "$c4" "$c5" "$c6" "$c7" "$c8"; do
    eval $c
done

#comment this if you want to see the working files.
rm -rf $dirname