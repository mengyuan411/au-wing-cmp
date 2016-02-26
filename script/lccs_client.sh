mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
echo $mac
type=''
if [ $# -ne 2 ]
then
	echo "Usage: lccs_client.sh <state> <dev_name> "
	exit 1
fi

if [ "$2" == "wlan0" ]
then
	type="radio0"
else
	type="radio1"
fi

content=`cat /tmp/wifiunion-uploads/$mac/client_$2.txt | awk 'NR == 1 { sum=0 } { sum+=$1; } END {printf "%f\n",sum/NR}'`
case $1 in 
1)
	sed -i "1s/.*/chan1,$(echo $content)/" /tmp/wifiunion-uploads/client_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/client_$2.txt
	;;
2)
	sed -i "2s/.*/chan6,$(echo $content)/" /tmp/wifiunion-uploads/client_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/client_$2.txt
	;;
-1)
	sed -i "3s/.*/chan11,$(echo $content)/" /tmp/wifiunion-uploads/client_decision_$2.txt
	echo "" > /tmp/wifiunion-uploads/$mac/client_$2.txt
	;;
0)
	echo "" > /tmp/wifiunion-uploads/$mac/client_$2.txt
	;;
esac




if [ $1 -eq -1 ]
then
	lines=`cat /tmp/wifiunion-uploads/client_decision_$2.txt | wc -l`
	if [ $lines -ne 3 ]
	then 
		echo "No enough decision information"
		exit 1
	fi
	client1=`cat /tmp/wifiunion-uploads/client_decision_$2.txt | grep chan1, | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 1 client: $client1"
	client6=`cat /tmp/wifiunion-uploads/client_decision_$2.txt | grep chan6 | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 6 client: $client6"
	client11=`cat /tmp/wifiunion-uploads/client_decision_$2.txt | grep chan11 | awk -F ',' '{print $2}' | awk -F '.' '{print $1}'`
	echo "channel 11 client: $client11"

	client=0
        chan=0
        if [ $client1 -lt $client6 ]
        then
                client=$client1
                chan=1
        else
                client=$client6
                chan=6
        fi

        if [ $client11 -lt $client ]
        then
                client=$client11
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
