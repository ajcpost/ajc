#!/bin/sh

input_dir=/home/y/logs/jboss
output_dir=~/tmp1
ip=211.232.184

files="server.log.2009-05-25"

for file in $files
do
input=$input_dir/$file
echo $input
output1=${output_dir}/plot-${file}
output2=${output_dir}/plot-ip-${file}
cat $input | grep "succesfully executed" | grep -v $ip | cut -d " " -f1,2,15,19 | sed "s/^\[//g" | sed "s/,.*\]//g" > $output1
cat $input| grep "succesfully executed" | grep $ip | cut -d " " -f1,2,15,19 | sed "s/^\[//g" | sed "s/,.*\]//g" > $output2
done
