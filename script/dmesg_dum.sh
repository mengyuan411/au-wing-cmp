sleeptime=$1

countneed=$2

while true
do 

	mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
	
	Ts=`date "+%s"`
	dmesg -c > /tmp/wifiunion-uploads/$mac/dmesg_data/$Ts
	echo $Ts
	#cat /tmp/wifiunion-uploads/$mac/dmesg_data/$Ts
	#cat /tmp/wifiunion-uploads/$mac/dmesg_data/$Ts | grep ampdu | sort -g -t ',' -k 5 -k 6 > /tmp/wifiunion-uploads/$mac/dmesg_data/$Ts
	cat /tmp/wifiunion-uploads/$mac/dmesg_data/$Ts | grep ampdu | sort -t ',' -n -k 5 -n -k 6
	filecount=`wc -l /tmp/wifiunion-uploads/$mac/dmesg_data/$Ts | awk '{print $1}'`
	echo $filecount
	tmp1=9
	tmp2=10
	num90=`expr $filecount \* $tmp1 / $tmp2`
	echo $num90
	this90sums=`cat /tmp/wifiunion-uploads/$mac/dmesg_data/$Ts | awk -F ',' -v m=$num90 'FNR==m {print $5 }'`
	echo $this90sums
	this90sumn=`cat /tmp/wifiunion-uploads/$mac/dmesg_data/$Ts | awk -F ',' -v m=$num90 'FNR==m {print $6 }'`
	echo $this90sumn
	isdigit=`awk 'BEGIN { if (match(ARGV[1],"^[0-9]+$") != 0) print "true"; else print "false" }' $this90sums`
		

	if [ $countneed == 1 -a $isdigit == "true" ]
	then 
		sums=`cat /tmp/wifiunion-uploads/$mac/numcount.txt | awk -F ',' '{print $1}'`
		sumn=`cat /tmp/wifiunion-uploads/$mac/numcount.txt | awk -F ',' '{print $2}'`
		count=`cat /tmp/wifiunion-uploads/$mac/numcount.txt | awk -F ',' '{print $3}'`
		count=`expr $count + 1`
		sums=`expr $sums + $this90sums`
		sumn=`expr $sumn + $this90sumn / 1000000000`
		echo "$sums,$sumn,$count" > /tmp/wifiunion-uploads/$mac/numcount.txt

		#python3 /lib/pch/sum_count.py /tmp/wifiunion-uploads/$mac/dmesg_data/$Ts $sums $sumn $count $mac
	#	cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep ampdu | awk -F ',' -v sums=$sums -v sumn=$sumn -v count=$count '{ if($5 > 0 || $6 > 0) sums+=$5; sumn+=$6; count+=1;} END {printf "%d,%d,%d\n",sums,sumn,count}' > /tmp/wifiunion-uploads/$mac/numcount.txt
	fi

	#/lib/pch/dmesg_rsyn.sh
	#rm /tmp/wifiunion-uploads/$mac/dmesg_data/*

	sleep $sleeptime
done

