#This is a script for summarizing sig. clusters in gfeat directories. MRP 1/6/2017
RED='\033[0;35m'
NC='\033[0m' # No Color

for f in $@; do
    for i in $f/cope?.feat/cluster_zstat?_std.txt; do
	echo -e $RED; ls $i; echo -e $NC
	cat $i
    done
done

