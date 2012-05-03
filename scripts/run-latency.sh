#!/bin/sh
for dir in `echo ac ch jp sk`
do
echo $dir
cd $dir
../gather $dir >> ../stats-$dir
cd ..
done
