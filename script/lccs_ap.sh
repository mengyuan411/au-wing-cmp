type=''
if [ $# -ne 2 ]
then
	echo "Usage: lccs_ap.sh <state> <dev_name> "
	exit 1
fi

if [ "$2" == "wlan0" ]
then
	type="radio0"
else
	type="radio1"
fi

if [ $1 -eq -1 ]
then
	num1=`iw dev $2 scan | grep primary | grep 1 |  wc -l`
	echo "channel 1: $num1" 
	num6=`iw dev $2 scan | grep primary | grep 6 |  wc -l` 
	echo "channel 6: $num6" 
	num11=`iw dev $2 scan | grep primary | grep 11 |  wc -l` 
	echo "channel 11: $num11" 
	num=0
	chan=0
	if [ $num1 -lt $num6 ]
	then
		num=$num1
		chan=1
	else
		num=$num6
		chan=6
	fi
	
	if [ $num11 -lt $num ]
	then
		num=$num11
		chan=11
	fi
	exec_time=`date '+%s'`
	echo "[$exec_time]: I will change $2 to Channel:$chan"	
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
