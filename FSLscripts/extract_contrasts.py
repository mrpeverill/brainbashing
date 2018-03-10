#This is a script to extract a matrix of contrasts from a .fsf file. useful when you don't want to rely on the Feat gui, which is slooooow.
import sys
import subprocess
import numpy as np

#print(len(sys.argv))
if len(sys.argv) != 2:
    print("Please specify one .fsf file as an argument")
    exit(1)
else:
    fsfFile=str(sys.argv)
    valcmd="grep '(con_real' %s | sed -e 's/set fmri(con_real//' -e 's/\./ /' -e 's/) / /'" % str(sys.argv[1])
    #print(cmd)
    stream=subprocess.Popen(valcmd,shell=True,stdout=subprocess.PIPE)
    #matrix=np.array([])
    xdim = 0
    ydim = 0
    values = list()
    for l in iter(stream.stdout.readline,''):
        fields = l.split()
        #print("field 0 is %s" % fields[0])
        #print("xdim is %s" % xdim)
        if int(fields[1]) > xdim:
            #print("updating...")
            xdim = int(fields[1])
            #print("now xdim is %s" % xdim)
        if int(fields[0]) > ydim:
            ydim = int(fields[0])
        values.append(fields[2])
    data = np.array(values)
    shape = (xdim, ydim)
    print(str(shape))
    data.shape = shape
    print(np.array_str(data))
    #Get ev names
    evcmd="grep 'set fmri(evtitle' %s" % str(sys.argv[1])
    evstream=subprocess.Popen(evcmd,shell=True,stdout=subprocess.PIPE)
    evnames=list()
    for l in iter(evstream.stdout.readline,''):
        s=l.split('"')
        #print(str(s))
        evnames.append(s[1])
    print(str(evnames))
    #Get contrast names
    concmd="grep 'set fmri(conname_real.' %s" % str(sys.argv[1])
    constream=subprocess.Popen(concmd,shell=True,stdout=subprocess.PIPE)
    connames=list([0])
    for l in iter(constream.stdout.readline,''):
        s=l.split('"')
        connames.append(s[1])
    print(str(connames))

