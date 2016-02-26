mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
echo $mac
type=''
if [ $# -ne 2 ]
then
	echo "Usage: lccs_au.sh <state> <dev_name> "
	exit 1
fi

if [ "$2" == "wlan0" ]
then
	type="radio0"
else
	type="radio1"
fi

avg_au=`cat /tmp/wifiunion-uploads/$mac/au_$2.txt | awk -F ',' '{print $3}' | awk 'NR == 1 { sum=0 } { sum+=$1; } END {printf "%f\n",sum/NR}'`
case $1 in 
1)
	sed -i "1s/.*/chan1,$(echo $avg_au)/" /tmp/wifiunion-uploads/au_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/au_$2.txt
	;;
2)
	sed -i "2s/.*/chan6,$(echo $avg_au)/" /tmp/wifiunion-uploads/au_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/au_$2.txt
	;;
-1)
	sed -i "3s/.*/chan11,$(echo $avg_au)/" /tmp/wifiunion-uploads/au_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/au_$2.txt
	;;
0)
	echo "" > /tmp/wifiunion-uploads/$mac/au_$2.txt
	;;
esac




if [ $1 -eq -1 ]
then
	lines=`cat /tmp/wifiunion-uploads/au_decision_$2.txt | wc -l`
	if [ $lines -ne 3 ]
	then 
		echo "No enough decision_$2 information"
		exit 1
	fi
	au1=`cat /tmp/wifiunion-uploads/au_decision_$2.txt | grep chan1, | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
        echo "channel 1 AU: $au1"
        au6=`cat /tmp/wifiunion-uploads/au_decision_$2.txt | grep chan6 | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
        echo "channel 6 AU: $au6"
        au11=`cat /tmp/wifiunion-uploads/au_decision_$2.txt | grep chan11 | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
        echo "channel 11 AU: $au11"

	au=0
        chan=0
        if [ $au1 -lt $au6 ]
        then
                au=$au1
                chan=1
        else
                au=$au6
                chan=6
        fi

        if [ $au11 -lt $au ]
        then
                au=$au11
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
