mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
echo $mac
type=''
if [ $# -lt 2 ]
then
	echo "Usage: lccs_dmac_90th.sh <state> <dev_name> "
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
#[NR/2]+arr[NR/2+1])/2}'`
#90th_wing=`cat /tmp/wifiunion-uploads/$mac/wing_$2.txt | awk 'NR == 1 { sum=0 } { if($1 > 0) sum+=$1; } END {printf "%f\n",sum/NR}'`
if [ $1 != 0 ]
then
        btime=$3
	dmesg -c > /tmp/wifiunion-uploads/$mac/dmesg_data/$exec_time
        cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep ampdu | awk -F ',' -v btime=$btime -v etime=$etime '{ if($2 >= btime && $2 <= etime) { print $0 }}' >> /tmp/wifiunion-uploads/$mac/dmac_90th_$2.txt
        #cat tmp/wifiunion-uploads/$mac/dmac_avg_$2.txt | sort -t ',' -k 4
        linenum=`wc -l  /tmp/wifiunion-uploads/$mac/dmac_90th_$2.txt | awk '{print $1}'`
        percent1=9
	percent2=10
        pos=`expr $linenum \* $percent1 / $percent2`
        dmac_90th=`cat /tmp/wifiunion-uploads/$mac/dmac_90th_$2.txt | sort -t ',' -nk 5 -nk 6 | sed -n "$pos p" | awk -F ',' '{printf "%f\n",($5*1000000+$6/1000)}'`
fi
#90th_dmac=`cat /tmp/wifiunion-uploads/$mac/dmac_90th_$2.txt | awk 'NR == 1 { sum=0 } { if($1 > 0) sum+=$1; } END {printf "%f,%d\n",sum/NR,NR}'`
case $1 in
1)
	sed -i "1s/.*/chan1,$(echo $dmac_90th)/" /tmp/wifiunion-uploads/dmac_90th_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/dmac_90th_$2.txt
	;;
2)
	sed -i "2s/.*/chan6,$(echo $dmac_90th)/" /tmp/wifiunion-uploads/dmac_90th_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/dmac_90th_$2.txt
	;;
-1)
	sed -i "3s/.*/chan11,$(echo $dmac_90th)/" /tmp/wifiunion-uploads/dmac_90th_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/dmac_90th_$2.txt
	;;
0)
	echo "" > /tmp/wifiunion-uploads/$mac/dmac_90th_$2.txt
	;;
esac




if [ $1 -eq -1 ]
then
	lines=`cat /tmp/wifiunion-uploads/dmac_90th_decision_$2.txt | wc -l`
	if [ $lines -ne 3 ]
	then
		echo "No enough decision information"
		exit 1
	fi
	dmac_90th1=`cat /tmp/wifiunion-uploads/dmac_90th_decision_$2.txt | grep chan1, | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 1 dmac_90th: $dmac_90th1"
	dmac_90th6=`cat /tmp/wifiunion-uploads/dmac_90th_decision_$2.txt | grep chan6 | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 6 dmac_90th: $dmac_90th6"
	dmac_90th11=`cat /tmp/wifiunion-uploads/dmac_90th_decision_$2.txt | grep chan11 | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 11 dmac_90th: $dmac_90th11"

	dmac_90th=0
        chan=0
        if [ $dmac_90th1 -lt $dmac_90th6 ]
        then
                dmac_90th=$dmac_90th1
                chan=1
        else
                dmac_90th=$dmac_90th6
                chan=6
        fi

        if [ $dmac_90th11 -lt $dmac_90th ]
        then
                dmac_90th=$dmac_90th11
                chan=11
        fi
	exec_time=`date '+%s'`
	PRO=`ps | grep 'rsync' | grep -v grep | wc -l`
        if  [ $PRO -le 0 ]
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
        if  [ $PRO -le 0 ]
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
