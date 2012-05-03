#!/bin/sh

input_dir=/home/y/logs/jboss
output_dir=~/tmp1
threshold=10000
ip=211.232.184
cutoff=17

#files="localhost_access_log.2009-05-22.log localhost_access_log.2009-05-23.log localhost_access_log.2009-05-24.log localhost_access_log.2009-05-25.log"
files="localhost_access_log.2009-05-26.log"

for file in $files
do
input=$input_dir/$file
echo $input
output1=${output_dir}/${threshold}-${file}
output2=${output_dir}/partial-${file}
output3=${output_dir}/compare-${file}

echo $output1
cat $input | awk -v t=$threshold '$10 > t { print $0 }' > $output1
echo $output2
cat $output1 | awk -v c=$cutoff '{split($4,a,":"); if(a[2] > c) print $0;}' > $output2

num=`cat $output1 | wc -l`
filter_num=`grep $ip $output1 | wc -l`
echo "total entries beyond $threshold:   $num" >> $output3
echo "total entries beyond $threshold by $ip:  $filter_num" >> $output3

partial_num=`cat $output2 | wc -l`
partial_filter_num=`grep $ip $output1 | wc -l`
echo "after $cutoff:00pm, total entries beyond $threshold:   $partial_num" >> $output3
echo "after $cutoff:00pm, total entries beyond $threshold by $ip:  $partial_filter_num" >> $output3
done
