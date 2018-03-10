#This python script will (eventually) get all the peak values from a given .nii.gz file at a variety of threshold, translate to MNI coordinates, and perform atlas lookups. This will be output in a table-ready format to be printed or turned in to a figure.
import os,sys,getopt,subprocess,numpy

#eventually we should use getopt to have optional parameters for threshold, increment, etc, but for now we'll make these static.
file=sys.argv[1]
if not os.path.isfile(file):
    print("File %s does not exist") % file

maxoutput=subprocess.check_output(["/mnt/home/mrpev/MRPscripts/printmaxima.sh",file])
#rawarray=numpy.fromstring(maxoutput)
print(maxoutput)
