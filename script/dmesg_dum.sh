sleeptime=$1

countneed=$2

while true
do 

	mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
	
	Ts=`date "+%s"`
	dmesg -c > /tmp/wifiunion-uploads/$mac/dmesg_data/$Ts


	if [ $countneed == 1 ]
	then 
		sums=`cat /tmp/wifiunion-uploads/$mac/numcount.txt | awk -F ',' '{print $1}'`
		sumn=`cat /tmp/wifiunion-uploads/$mac/numcount.txt | awk -F ',' '{print $2}'`
		count=`cat /tmp/wifiunion-uploads/$mac/numcount.txt | awk -F ',' '{print $3}'`
		cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep ampdu | awk -F ',' -v sums=$sums -v sumn=$sumn -v count=$count '{ if($5 > 0 || $6 > 0) sums+=$5; sumn+=$6; count+=1;} END {printf "%d,%d,%d\n",sums,sumn,count}' > /tmp/wifiunion-uploads/$mac/numcount.txt
	fi

	/lib/pch/dmesg_rsyn.sh
	#rm /tmp/wifiunion-uploads/$mac/dmesg_data/*

	sleep $sleeptime
done

