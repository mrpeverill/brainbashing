#!/usr/local/anaconda/bin/python
#This script takes any number of three column fsl event files and outputs a .m matlab script suitable to generate timing parameters.
import sys
import pandas
print 'Number of arguments:', len(sys.argv[1:]), 'arguments.'
print 'Argument List:', str(sys.argv[1:])

llist=['names=cell(1,%s);' % len(sys.argv[1:]), 
       'onsets=cell(1,%s);' % len(sys.argv[1:]), 
       'durations=cell(1,%s);' % len(sys.argv[1:])] 

#Get the EVs from the fsl files.
for i in enumerate(sys.argv[1:], start=1):
    try:
        f = open(i[1])
    except:
        print "Could not open file %s" % i[1]
        exit(1)
    df = pandas.read_csv(f, delim_whitespace=True, header=None).sort_index(by=0)
    llist.append("names{%s}='%s';" % i)
    #This is awful, sorry:
    llist.append("onsets{%s}=[%s];" % (i[0], ', '.join(["{0:.4f}".format(o) for o in df[0].tolist()])))
    llist.append("durations{%s}=%s;" % (i[0], str(df[1].tolist())))
    f.close()

w = open('output.m','w')
print 'output.m file text'    
for l in llist:
    print l
    w.write("%s\n" % l)
w.close()

print "\nWrote output.m"
#print(str(llist))


