#!/bin/bash
# Warren Winter, 5/28/13	
# Modified 10/30/2013 by Matt Peverill:
# Modified 1/13/2014 by Matt Peverill:
#Added configuration section to allow cleaner selection of stats to run.

##Config (you need to fill this out with what stats you are trying to calculate)
#Aseg gets prep'd automatically by recon-all, but the others need to be prepped specifically.

#Todo: the config should be moved in to command line options.

doAparc=true
doAparc2009=false
doYeo=false
doMcDonnell=false
doSpeechparc=false
#doHippofields=true
##/Config

#First lets make sure the environment is set up.
if [[ $SUBJECTS_DIR != `pwd` ]]; then
    read -p "You're not running the script from \$SUBJECTS_DIR (${SUBJECTS_DIR}). Press any key to continue or Ctrl+c to exit."
fi

#Now we get our subject list.
if [ $# -eq 0 ]; then
    echo "List the subjects' subject IDs, separated by spaces (you could also list them as arguments to the command):"
    read subjsinput
    subjids="$subjsinput"
else
    subjids=$( printf '%s ' "$@" )
fi

#Now we set up the output file.
echo '

What do you want to call the file? (_allstats.txt will be appended to what you type.)

'
read tabletitle
echo '

Building stats tables and combining them into one file .

'
mkdir statstmp

##'standard' aparc
if $doAparc; then
    echo "Collecting aparc 2005 stats..."
    aparcstats2table --subjects $subjids --hemi rh --meas area --transpose --tablefile statstmp/rh_aparc_surfarea
    aparcstats2table --subjects $subjids --hemi rh --meas volume --transpose --tablefile statstmp/rh_aparc_volume
    aparcstats2table --subjects $subjids --hemi rh --meas thickness --transpose --tablefile statstmp/rh_aparc_thickness

    aparcstats2table --subjects $subjids --hemi lh --meas area --transpose --tablefile statstmp/lh_aparc_surfarea
    aparcstats2table --subjects $subjids --hemi lh --meas volume --transpose --tablefile statstmp/lh_aparc_volume
    aparcstats2table --subjects $subjids --hemi lh --meas thickness --transpose --tablefile statstmp/lh_aparc_thickness
fi

#aparc.2009
if $doAparc2009; then
    echo "Collecting aparc 2009 stats..."
    aparcstats2table --subjects $subjids --hemi rh -p aparc.a2009s --meas area --transpose --tablefile statstmp/rh_aparc2009_surfarea
    aparcstats2table --subjects $subjids --hemi rh -p aparc.a2009s --meas volume --transpose --tablefile statstmp/rh_aparc2009_volume
    aparcstats2table --subjects $subjids --hemi rh -p aparc.a2009s --meas thickness --transpose --tablefile statstmp/rh_aparc2009_thickness

    aparcstats2table --subjects $subjids --hemi lh -p aparc.a2009s --meas area --transpose --tablefile statstmp/lh_aparc2009_surfarea
    aparcstats2table --subjects $subjids --hemi lh -p aparc.a2009s --meas volume --transpose --tablefile statstmp/lh_aparc2009_volume
    aparcstats2table --subjects $subjids --hemi lh -p aparc.a2009s --meas thickness --transpose --tablefile statstmp/lh_aparc2009_thickness
fi

##Mcdonnell Networks
if $doMcDonnell; then
    echo "Collecting McDonnell networks stats..."
    aparcstats2table --subjects $subjids --hemi rh --parc McDonnell_networks --meas area --transpose --tablefile statstmp/rh_McDonnell_networks_area
    aparcstats2table --subjects $subjids --hemi rh --parc McDonnell_networks --meas volume --transpose --tablefile statstmp/rh_McDonnell_networks_volume
    aparcstats2table --subjects $subjids --hemi rh --parc McDonnell_networks --meas thickness --transpose --tablefile statstmp/rh_McDonnell_networks_thickness

    aparcstats2table --subjects $subjids --hemi lh --parc McDonnell_networks --meas area --transpose --tablefile statstmp/lh_McDonnell_networks_area
    aparcstats2table --subjects $subjids --hemi lh --parc McDonnell_networks --meas volume --transpose --tablefile statstmp/lh_McDonnell_networks_volume
    aparcstats2table --subjects $subjids --hemi lh --parc McDonnell_networks --meas thickness --transpose --tablefile statstmp/lh_McDonnell_networks_thickness
fi

##Yeo Networks
if $doYeo; then
    echo "Collecting Yeo networks stats..."
    aparcstats2table --subjects $subjids --hemi rh --parc Yeo2011_17Networks_N1000 --meas area --transpose --tablefile statstmp/rh_aparc_Yeo_17_surfarea_temp.txt
    aparcstats2table --subjects $subjids --hemi rh --parc Yeo2011_17Networks_N1000 --meas volume --transpose --tablefile statstmp/rh_aparc_Yeo_17_volume_temp.txt

    aparcstats2table --subjects $subjids --hemi rh --parc Yeo2011_7Networks_N1000 --meas area --transpose --tablefile statstmp/rh_aparc_Yeo_7_surfarea_temp.txt
    aparcstats2table --subjects $subjids --hemi rh --parc Yeo2011_7Networks_N1000 --meas volume --transpose --tablefile statstmp/rh_aparc_Yeo_7_volume_temp.txt
    aparcstats2table --subjects $subjids --hemi rh --parc Yeo2011_7Networks_N1000 --meas thickness --transpose --tablefile statstmp/rh_aparc_Yeo_7_thickness_temp.txt

    aparcstats2table --subjects $subjids --hemi lh --parc Yeo2011_17Networks_N1000 --meas area --transpose --tablefile statstmp/lh_aparc_Yeo_17_surfarea_temp.txt
    aparcstats2table --subjects $subjids --hemi lh --parc Yeo2011_17Networks_N1000 --meas volume --transpose --tablefile statstmp/lh_aparc_Yeo_17_volume_temp.txt

    aparcstats2table --subjects $subjids --hemi lh --parc Yeo2011_7Networks_N1000 --meas area --transpose --tablefile statstmp/lh_aparc_Yeo_7_surfarea_temp.txt
    aparcstats2table --subjects $subjids --hemi lh --parc Yeo2011_7Networks_N1000 --meas volume --transpose --tablefile statstmp/lh_aparc_Yeo_7_volume_temp.txt
    aparcstats2table --subjects $subjids --hemi lh --parc Yeo2011_7Networks_N1000 --meas thickness --transpose --tablefile statstmp/lh_aparc_Yeo_7_thickness_temp.txt
fi

#Speechparc stats
if $doSpeechparc; then
    echo "Collecting Speechparc stats..."
    aparcstats2table --subjects $subjids --hemi rh --parc speechparc --meas area --transpose --tablefile statstmp/rh_speechparc_area.txt
    aparcstats2table --subjects $subjids --hemi rh --parc speechparc --meas volume --transpose --tablefile statstmp/rh_speechparc_volume.txt
    aparcstats2table --subjects $subjids --hemi rh --parc speechparc --meas thickness --transpose --tablefile statstmp/rh_speechparc_thickness.txt

    aparcstats2table --subjects $subjids --hemi lh --parc speechparc --meas area --transpose --tablefile statstmp/lh_speechparc_area.txt
    aparcstats2table --subjects $subjids --hemi lh --parc speechparc --meas volume --transpose --tablefile statstmp/lh_speechparc_volume.txt
    aparcstats2table --subjects $subjids --hemi lh --parc speechparc --meas thickness --transpose --tablefile statstmp/lh_speechparc_thickness.txt
fi

asegstats2table --subjects $subjids --transpose --meas volume --tablefile aseg_temp &

#now we wait for all those to finish.
wait

sed "s/\t/\taseg_volume\t/1" aseg_temp > ${tabletitle}_allstats.txt

for i in statstmp/*
do
    b=`basename $i`
    sed "s/\t/\t$b\t/1" $i | tail -q -n +2 >> ${tabletitle}_allstats.txt
done

rm -rf statstmp
rm aseg_temp
