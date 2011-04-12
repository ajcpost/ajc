#!/bin/sh

for file in `ls`
do
echo $file
cat $file| sed "s/(/( /g" | awk ' {split ($1,a,"/"); if ( ($10>=1) || (index(a[2],"Target") !=0) || ($10<0.2 && $15>100) || ($10>=0.2 && $10<0.5 && $15>50) || ($10>=0.5 && $10<1 && $15>20) ) print a[1] " " a[2] " " $10 " " $15;}' >> op
#echo "" >> op
#echo "EOF" >> op
#echo "" >> op
done

