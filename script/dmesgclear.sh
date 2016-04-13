while rp==1
do
	exec_time=`date '+%s'`
	dmesg -c > /tmp/dmesglog/$exec_time
	sleep 2
done