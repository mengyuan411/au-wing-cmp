mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
echo $mac
type=''
if [ $# -lt 2 ]
then
	echo "Usage: lccs_dmaci_90th.sh <state> <dev_name> "
	exit 1
fi

if [ "$2" == "wlan0" ]
then
	type="radio0"
else
	type="radio1"
fi

exec_time=`date '+%s'`
etime=$exec_time
#median=`cat /tmp/wifiunion-uploads/wing.txt  | sort | awk '{arr[NR]=$1} END { if (NR%2==1) print arr[(NR+1)/2]; else print (arr
#[NR/2]+arr[NR/2+1])/2}'`
#90th_wing=`cat /tmp/wifiunion-uploads/$mac/wing_$2.txt | awk 'NR == 1 { sum=0 } { if($1 > 0) sum+=$1; } END {printf "%f\n",sum/NR}'`
#90th_dmaci=`cat /tmp/wifiunion-uploads/$mac/dmaci_90th_$2.txt | awk 'NR == 1 { sum=0 } { if($1 > 0) sum+=$1; } END {printf "%f,%d\n",sum/NR,NR}'`
if [ $1 != 0 ]
then
        btime=$3
	dmesg -c > /tmp/wifiunion-uploads/$mac/dmesg_data/$exec_time
        cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep ampdu | awk -F ',' -v btime=$btime -v etime=$etime '{ if($2 >= btime && $2 <= etime) { print $0 }}' >> /tmp/wifiunion-uploads/$mac/dmaci_90th_$2.txt
        #cat tmp/wifiunion-uploads/$mac/dmac_avg_$2.txt | sort -t ',' -k 4
        linenum=`wc -l  /tmp/wifiunion-uploads/$mac/dmaci_90th_$2.txt | awk '{print $1}'`
        percent1=9
        percent2=10
        pos=`expr $linenum \* $percent1 / $percent2`
        dmaci_90th=`cat /tmp/wifiunion-uploads/$mac/dmaci_90th_$2.txt | sort -t ',' -nk 3 -nk 4 | sed -n "$pos p" | awk -F ',' '{printf "%f\n",($3*1000000+$4/1000)}'`
fi
case $1 in
1)
	sed -i "1s/.*/chan1,$(echo $dmaci_90th)/" /tmp/wifiunion-uploads/dmaci_90th_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/dmaci_90th_$2.txt
	;;
2)
	sed -i "2s/.*/chan6,$(echo $dmaci_90th)/" /tmp/wifiunion-uploads/dmaci_90th_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/dmaci_90th_$2.txt
	;;
-1)
	sed -i "3s/.*/chan11,$(echo $dmaci_90th)/" /tmp/wifiunion-uploads/dmaci_90th_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/dmaci_90th_$2.txt
	;;
0)
	echo "" > /tmp/wifiunion-uploads/$mac/dmaci_90th_$2.txt
	;;
esac




if [ $1 -eq -1 ]
then
	lines=`cat /tmp/wifiunion-uploads/dmaci_90th_decision_$2.txt | wc -l`
	if [ $lines -ne 3 ]
	then
		echo "No enough decision information"
		exit 1
	fi
	dmaci_90th1=`cat /tmp/wifiunion-uploads/dmaci_90th_decision_$2.txt | grep chan1, | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 1 dmaci_90th: $dmaci_90th1"
	dmaci_90th6=`cat /tmp/wifiunion-uploads/dmaci_90th_decision_$2.txt | grep chan6 | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 6 dmaci_90th: $dmaci_90th6"
	dmaci_90th11=`cat /tmp/wifiunion-uploads/dmaci_90th_decision_$2.txt | grep chan11 | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 11 dmaci_90th: $dmaci_90th11"

	dmaci_90th=0
        chan=0
        if [ $dmaci_90th1 -lt $dmaci_90th6 ]
        then
                dmaci_90th=$dmaci_90th1
                chan=1
        else
                dmaci_90th=$dmaci_90th6
                chan=6
        fi

        if [ $dmaci_90th11 -lt $dmaci_90th ]
        then
                dmaci_90th=$dmaci_90th11
                chan=11
        fi
	exec_time=`date '+%s'`
	PRO=`ps | grep 'rsync' | grep -v grep | wc -l`
        if [ $PRO -le 0 ]
        then
                chmod 777 /lib/pch/rsync.sh
                /lib/pch/rsync.sh
                rm /tmp/wifiunion-uploads/$mac/dmesg_data/*
        fi
	echo "[$exec_time]: I will change $type to Channel:$chan"
	uci set wireless.$type.channel=$chan
	uci commit
	wifi
else
	exec_time=`date '+%s'`
	PRO=`ps | grep 'rsync' | grep -v grep | wc -l`
        if [ $PRO -le 0 ]
        then
                chmod 777 /lib/pch/rsync.sh
                /lib/pch/rsync.sh
                rm /tmp/wifiunion-uploads/$mac/dmesg_data/*
        fi
	chan=`expr $1 \\* 5 + 1`
	echo "[$exec_time]: I will change $type to Channel:$chan"
	uci set wireless.$type.channel=$chan
	uci commit
	wifi

fi
