#Freesurfer's recon-all command is powerful, but needs a lot of knowledge to run correctly. Often, it needs to be run by many people who don't know a lot about the command line or Freesurfer. This script sets up project-specific config files that remain static throughout a project's lifetime, provides an easy front-end for end-users to run recon-all, and allows recon-all to be run in a batch format with support for grid-processing.
#The original batch-reconall had each project's setup hard-coded in the script. This created risk of settings being thoughtlessly (mis)applied to new projects, so the new version relies on the existence of configuration files in each project.
#v2 Matt Peverill 9-12-2016 mrpeverill@gmail.com

USAGE="Usage: batch-reconall2.sh [OPTIONS]... [SUBJECTS]...
Parses configuration files for recon-all in a parent directory, then runs recon-all with the specified options. By default, commands will be output to some sort of task scheduler (such as sge or MOSIX).

Mandatory arguments to long options are mandatory for short options too.
  -n		Dry-run - don\'t actually run recon-all - just list the commands that would be run.
  -p (dir)	Expect configuration file in the given directory. Defaults to SUBJECT_DIR/../
  -h		Print this help message and exit.
  -c		Create empty configuration file in specified directory and exit.
  -s (1-5)	Stage: specify stage at the command line instead of at the prompt.

Stages are as follows:
(1) recon-all from raw image data
(2) recon-all after making brainmask edits (stages 6-31)
(3) recon-all after adding control points (stages 12-31)
(4) recon-all after editing wm.mgz (stages 15-31) (NOTE: picking a lower stage over-writes WM edits!)

You should specify the lowest number that applies (so if you edited brainmask and control points, pick 2.

OR pick:
(5) recon-all for hippocampal subfields."

while getopts ":np:hcs:" opt; do
  case $opt in
    n)
	echo "Dry-run: will not run recon-all!"
	dry=1
	;;
    p)
	pset=$OPTARG
	;;
    h)
	echo "$USAGE"
	exit 0
	;;
    c)
	createonly=1
	;;
    s)
	choice=$OPTARG
	;;
    \?)
	echo "Invalid option: -$OPTARG" >&2
	exit 1
      ;;
  esac
done
shift $(expr $OPTIND - 1 )

##Section 1: Check everything.
#Is SUBJECTS_DIR specified, and is it where we are?
if [[ $SUBJECTS_DIR != `pwd` ]]; then
    read -p "You're not running the script from \$SUBJECTS_DIR (${SUBJECTS_DIR}). Press any key to continue in ${SUBJECTS_DIR} or Ctrl+c to exit." >&2
fi
#Print and check parent directory
if [ -z $pset ]; then
    pdir=$SUBJECTS_DIR/../
else
    pdir=$pset
fi
if [ ! -d "$pdir" ]; then
    echo "$pdir was specified as parent, but it does not exist, is not a directory, or you do not have read permissions to it" >&2
    exit 1
else
    echo "Using Parent Directory $pdir"
fi

#Process configuration file
configfile=$pdir/batch-reconall.cfg
if [ ! -f $configfile ] || [ $createonly ]; then
    if [ ! -f $configfile ]; then
	read -p "$configfile does not exist. Press any key to create a template, or Ctrl+c to exit." >&2
    else
	echo "Cannot create config file $configfile - file already exists!" >&2
	exit 1
    fi
    cat > $configfile <<EOF
#This is the Config file for batch reconall. You should review it at the onset of each project.

#This is the command that prefixes recon-all, mostly for task scheduling.
qcommand="qsub -q vmpfc.q -V"

#gca-dir
gcadir="/usr/local/freesurfer/stable5_3/average/"
#gca. the '-gca' part should be left in - if you do not want to use gca you can simply make the variable blank.
gca="RB_all_2011-10-25.gca"
#gca-skull
gcaskull="RB_all_withskull_2011-10-25.gca"

#Uncomment this if you want Freesurfer to try to use a T2 image to help define the pial surface
T2choice="yes"

#These are options that should be passed to recon-all in everything but the hippocampal subfields option. They change the assumptions the program makes about images.
standard_ops="-3T -mprage -nowmsa"

#If you need to specify expert options this is the way to do it.
#expertopts="-xopts-overwrite -expert $pdir/expert.opts"

##The following get used for first run of recon-all - not currently implemented.
#Where are the raw images located (parent of the subject folders). $pdir uses the parent directory from batch-reconall2, which is $SUBJECTS_DIR/../ by default.
#rawpath="$pdir"

#This is the search string for what T1 and T2 folders look like. They should only be used for stage one. You can add multiple conditions just like the "foo" and "bar" conditions below. Its safe to have extra - it will always prompt you before using them.
#eg. this would match SUBJECT/memprage/T1.nii.gz
#T1searcharray=( "memprage/T1.nii.gz" "foo" )
#T2searcharray=( "*T2_SPACE*" "bar" )


EOF
	echo "Created config file $configfile . You should review it and then re-run batch-reconall2.sh"
	exit 0
fi
source $configfile

#If GCA specified, does it exist?
if [ -f $gcadir/$gca ]; then
    gca_c="-gca $gca"
else
    echo "GCA is specified as $gcadir/$gca, but that file does not exist" >&2
    exit 1
fi

if [ -f $gcadir/$gcaskull ]; then
    gcaskull_c="-gca-skull $gca"
else
    echo "GCA-skull is specified as $gcadir/$gcaskull, but that file does not exist" >&2
    exit 1
fi
gcadir_c="-gca-dir $gcadir"
gcastring="$gcadir_c $gca_c $gcaskull_c"

#What are we doing?
if [ ! -e $choice ]; then
    echo "Stage $choice specified"
else
    echo '
Choose one of the following options:

(1) recon-all from raw image data
(2) recon-all after making brainmask edits (stages 6-31)
(3) recon-all after adding control points (stages 12-31)
(4) recon-all after editing wm.mgz (stages 15-31) (NOTE: picking a lower stage over-writes WM edits!)

Pick the lowest number that applies (so if you edited brainmask and control points, pick 2.

OR pick:
(5) recon-all for hippocampal subfields.'
    read choice
fi

while ! [[ $choice =~ ^[1-5]+$ ]] || [[ $choice -gt 5 ]] || [[ $choice -lt 1 ]]; do
	read -p "Stage selected is Not a valid option.  Enter an integer from 1 to 5: " choice
done

if [[ $choice == 1 ]]; then
    echo "None of our studies currently use this script for raw image data, so it's not implemented here, sorry"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "
List the subjects' subject IDs, separated by spaces (you could also list them as arguments to the command):"
    read subjsinput
    subjects=( "$subjsinput" )
else
    subjects=( $@ )
    echo "You listed the following subjects as command arguments:."
    echo $@
fi

function recon_wrap() {
    command="$qcommand -o $2.output -e $2.errors $1  &"
    echo "Running recon-all (steps $3)"
    echo $command
#If you comment out this eval command the script will just tell you what it would do:
    if [ ! $dry ]; then
	eval $command
    fi
}

for s in ${subjects[@]}; do
    log="${SUBJECTS_DIR}/${s}/${USER}_last_batch_recon"
    echo -e "\e[00;35mStarting recon-all for subject number $s. Output stored in $log\e[00m"
    if [[ $T2choice = "yes" ]] && [[ $choice -gt 1 ]]; then
	if [[ -e ${SUBJECTS_DIR}/$s/mri/T2.mgz ]]; then
	    echo "Found T2 for $s"
	    T2="-T2pial"
	else
	    echo "No T2 Found"
	    T2=""
	fi
    fi

    if [[ $choice -eq 2 ]]; then 
	stages="6-31"
	command="/usr/local/freesurfer/stable5_3/bin/recon-all -s $s $T2 -autorecon2 -autorecon3 $gcastring $standard_ops $expertopts"
    elif [[ $choice -eq 3 ]]; then 
	stages="12-31"
	command="/usr/local/freesurfer/stable5_3/bin/recon-all -s $s $T2 -autorecon2-cp -autorecon3 $gcastring $standard_ops $expertopts"
    elif [[ $choice -eq 4 ]]; then 
	stages="15-31"
	command="/usr/local/freesurfer/stable5_3/bin/recon-all -s $s $T2 -autorecon2-wm -autorecon3 $gcastring $standard_ops $expertopts"
    elif [[ $choice -eq 5 ]]; then
    	stages="hippocampal subfields"
	command="/usr/local/freesurfer/stable5_3/bin/recon-all -s $s -hippo-subfields"
    fi
    recon_wrap "$command" "$log" "$stages" "$s"
done

echo -e "\e[01;31m
To list your running jobs, you can type 'qstat' at the terminal 
Output/error messages are written within each subjects freesurfer folder\e[00m"
