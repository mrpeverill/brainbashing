#!/bin/bash
#This takes two three column fsl event files and produces one EV of $1 - $2 and one of $1 + $2
#USAGE: [-t] (first ev file) (second ev file)

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
output_file=""
verbose=0

while getopts ":td:" opt; do
    case "$opt" in
	t)
	    echo "Running in test mode" >&2
	    test=1
	    ;;
	d)
	    echo "Directory Destination is $OPTARG"
	    if [ ! -d $OPTARG ]; then
		echo "ERROR: $OPTARG is not a valid directory" >&2
		exit 1
	    else
		dir=$OPTARG
	    fi
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
    esac
done

shift $((OPTIND-1))

if [ -z ${1+x} ] || [ -z ${2+x} ]; then
    echo "You did not specify two files..."
    exit 1
fi

if [ ! -s $1 ]; then
    echo "file $1 does not exist or is empty" >&2
    exit 1
fi
if [ ! -s $2 ]; then
    echo "file $2 does not exist or is empty" >&2
    exit 1
fi

ofname1=`basename $1 .txt`_MINUS_`basename $2 .txt`.txt
ofname2=`basename $1 .txt`_PLUS_`basename $2 .txt`.txt


minus="{ cat $1 & awk '{\$3=\$3*-1;print}' $2; } | sort -k1 -n"
plus="cat $1 $2 | sort -k1 -n"

echo "ofname1 is $ofname1 :"
eval $minus
echo ""
echo "ofname2 is $ofname2 :"
eval $plus
    
if test=0; then
    eval $minus > $dir/$ofname1
    eval $plus > $dir/$ofname2
fi

    
