mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
echo $mac
type=''
if [ $# -ne 2 ]
then
	echo "Usage: lccs_dmac_avg.sh <state> <dev_name> "
	exit 1
fi

if [ "$2" == "wlan0" ]
then
	type="radio0"
else
	type="radio1"
fi

#median=`cat /tmp/wifiunion-uploads/wing.txt  | sort | awk '{arr[NR]=$1} END { if (NR%2==1) print arr[(NR+1)/2]; else print (arr
#[NR/2]+arr[NR/2+1])/2}'`
#avg_wing=`cat /tmp/wifiunion-uploads/$mac/wing_$2.txt | awk 'NR == 1 { sum=0 } { if($1 > 0) sum+=$1; } END {printf "%f\n",sum/NR}'`
avg_dmac=`cat /tmp/wifiunion-uploads/$mac/dmac_avg_$2.txt | awk 'NR == 1 { sum=0 } { if($1 > 0) sum+=$1; } END {printf "%f,%d\n",sum/NR,NR}'`
case $1 in 
1)
	sed -i "1s/.*/chan1,$(echo $avg_dmac)/" /tmp/wifiunion-uploads/dmac_avg_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/dmac_avg_$2.txt
	;;
2)
	sed -i "2s/.*/chan6,$(echo $avg_dmac)/" /tmp/wifiunion-uploads/dmac_avg_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/dmac_avg_$2.txt
	;;
-1)
	sed -i "3s/.*/chan11,$(echo $avg_dmac)/" /tmp/wifiunion-uploads/dmac_avg_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/dmac_avg_$2.txt
	;;
0)
	echo "" > /tmp/wifiunion-uploads/$mac/dmac_avg_$2.txt
	;;
esac




if [ $1 -eq -1 ]
then
	lines=`cat /tmp/wifiunion-uploads/dmac_avg_decision_$2.txt | wc -l`
	if [ $lines -ne 3 ]
	then 
		echo "No enough decision information"
		exit 1
	fi
	dmac_avg1=`cat /tmp/wifiunion-uploads/dmac_avg_decision_$2.txt | grep chan1, | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 1 dmac_avg: $dmac_avg1"
	dmac_avg6=`cat /tmp/wifiunion-uploads/dmac_avg_decision_$2.txt | grep chan6 | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 6 dmac_avg: $dmac_avg6"
	dmac_avg11=`cat /tmp/wifiunion-uploads/dmac_avg_decision_$2.txt | grep chan11 | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 11 dmac_avg: $dmac_avg11"

	dmac_avg=0
        chan=0
        if [ $dmac_avg1 -lt $dmac_avg6 ]
        then
                dmac_avg=$dmac_avg1
                chan=1
        else
                dmac_avg=$dmac_avg6
                chan=6
        fi

        if [ $dmac_avg11 -lt $dmac_avg ]
        then
                dmac_avg=$dmac_avg11
                chan=11
        fi
	exec_time=`date '+%s'`
	echo "[$exec_time]: I will change $type to Channel:$chan"	
	uci set wireless.$type.channel=$chan
	uci commit
	wifi
else
	exec_time=`date '+%s'`
	chan=`expr $1 \\* 5 + 1`
	echo "[$exec_time]: I will change $type to Channel:$chan"	
	uci set wireless.$type.channel=$chan
	uci commit
	wifi

fi
