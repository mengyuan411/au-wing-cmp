mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
echo $mac
type=''
if [ $# -ne 2 ]
then
	echo "Usage: lccs_dmaci_50th.sh <state> <dev_name> "
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
#50th_wing=`cat /tmp/wifiunion-uploads/$mac/wing_$2.txt | awk 'NR == 1 { sum=0 } { if($1 > 0) sum+=$1; } END {printf "%f\n",sum/NR}'`
50th_dmaci=`cat /tmp/wifiunion-uploads/$mac/dmaci_50th_$2.txt | awk 'NR == 1 { sum=0 } { if($1 > 0) sum+=$1; } END {printf "%f,%d\n",sum/NR,NR}'`
case $1 in
1)
	sed -i "1s/.*/chan1,$(echo $50th_dmaci)/" /tmp/wifiunion-uploads/dmaci_50th_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/dmaci_50th_$2.txt
	;;
2)
	sed -i "2s/.*/chan6,$(echo $50th_dmaci)/" /tmp/wifiunion-uploads/dmaci_50th_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/dmaci_50th_$2.txt
	;;
-1)
	sed -i "3s/.*/chan11,$(echo $50th_dmaci)/" /tmp/wifiunion-uploads/dmaci_50th_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/dmaci_50th_$2.txt
	;;
0)
	echo "" > /tmp/wifiunion-uploads/$mac/dmaci_50th_$2.txt
	;;
esac




if [ $1 -eq -1 ]
then
	lines=`cat /tmp/wifiunion-uploads/dmaci_50th_decision_$2.txt | wc -l`
	if [ $lines -ne 3 ]
	then
		echo "No enough decision information"
		exit 1
	fi
	dmaci_50th1=`cat /tmp/wifiunion-uploads/dmaci_50th_decision_$2.txt | grep chan1, | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 1 dmaci_50th: $dmaci_50th1"
	dmaci_50th6=`cat /tmp/wifiunion-uploads/dmaci_50th_decision_$2.txt | grep chan6 | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 6 dmaci_50th: $dmaci_50th6"
	dmaci_50th11=`cat /tmp/wifiunion-uploads/dmaci_50th_decision_$2.txt | grep chan11 | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 11 dmaci_50th: $dmaci_50th11"

	dmaci_50th=0
        chan=0
        if [ $dmaci_50th1 -lt $dmaci_50th6 ]
        then
                dmaci_50th=$dmaci_50th1
                chan=1
        else
                dmaci_50th=$dmaci_50th6
                chan=6
        fi

        if [ $dmaci_50th11 -lt $dmaci_50th ]
        then
                dmaci_50th=$dmaci_50th11
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
