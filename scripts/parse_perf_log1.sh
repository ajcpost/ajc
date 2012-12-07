#!/bin/sh
#
# Usage: parse_perf_log1.sh <dir> -startdate <mmm dd> -enddate <mmm dd> -starthour <hh> -endhour <hh> -removedup <comma separated column nos>
#    Extracts perf entries during the given duration, removes duplicates based on
#


_combined_perf_file=input.txt
_combined_scrubbed_file=output.txt


# Fetch all the perf files, strip unwanted chars, ^M etc and create 
# a super-large file. If analyzed individually, awk results could be
# slightly different
echo "Cleaning old files if any, $_combined_perf_file
rm $_combined_perf_file
for file in `find $1 -name perf*.csv -print`
do
strings $file  | col -b >> $_combined_perf_file
done

# Remove duplicates based on col4(node), col6(user)
cat input.txt | egrep ' Nov 18 05:| Nov 18 06:| Nov 18 07:| Nov 18 08:' | awk '!arr[$4,$6]++' FS=, > output.txt
cat input.txt | egrep ' Nov 19 05:| Nov 19 06:| Nov 19 07:| Nov 19 08:' | awk '!arr[$4,$6]++' FS=, >> output.txt
cat input.txt | egrep ' Nov 20 05:| Nov 20 06:| Nov 20 07:| Nov 20 08:' | awk '!arr[$4,$6]++' FS=, >> output.txt
cat input.txt | egrep ' Nov 21 05:| Nov 21 06:| Nov 21 07:| Nov 21 08:' | awk '!arr[$4,$6]++' FS=, >> output.txt
cat input.txt | egrep ' Nov 22 05:| Nov 22 06:| Nov 22 07:| Nov 22 08:' | awk '!arr[$4,$6]++' FS=, >> output.txt



#strings $file | col -b > perf.csv
#cat perf.csv | egrep 'Tue Nov 20 05:|Tue Nov 20 06:|Tue Nov 20 07:|Tue Nov 20 08:' > p.csv
#awk '!arr[$3]++' FS=, perf.csv
