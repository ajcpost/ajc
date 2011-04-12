for day in `echo 17 18 19 20 21 22`
do
#echo $day
for hour in `echo 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23`
do
echo -n "$day-NOV-10 $hour -- "
grep "$day-NOV-10 $hour." /tmp/queue | wc -l
done
done
