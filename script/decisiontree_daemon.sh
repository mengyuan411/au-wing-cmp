#compare dmac_avg dmac_50th dmac_90th dmaci_avg dmaci_50th dmaci_90th

if [ $# -lt 4 ]
then 
	echo "Usage: lccs_decision_daemon.sh <gap_time> <wlan_type> <roundnum> <T_silent_thereshold> <continue_flag>"
	echo " "
	echo "       gap_time      : gap_time=10 means every 10s we will get a slow or fast"
	echo "       wlan_type     : wlan0 | wlan1"
	echo "       roundnum      : the num of all gaps in one same channel"
	#echo "       T_silent_time : T_silent=30 means even after T_run_time, we have to find the "
	#echo "                                   relative silent time to adjuct the channel"
	#echo "       T_silent      : T_silent=0 means if wap sends less than 0 bytes "
	echo "       continue_flag : 1|0 if execute the algorithm continuely or just one round"
	#echo "                                    in $prob_intervals interverl, then flag this $prob_interval seconds as siltent"
	
	exit 1
fi

gap_time=$1
roundnum=$3


mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
#sleep 124
#state_large=0
pre_bytes=0
prob_interval=10
run_time=`expr 0 - $prob_interval`
silent_time=`expr 0 - $prob_interval`
flag_sent_data=1
flag_time_to_change=0
flag_choose=0  #if continue choose a new channel


#init every ap to channel 1 at first
type=0
if [ "$2" == "wlan0" ]
then
	type="radio0"
else
	type="radio1"
fi
#echo "0,0,0" > /tmp/wifiunion-uploads/$mac/numcount.txt


#echo "chan1,0" > /tmp/wifiunion-uploads/ap_decision_$2.txt
#echo "chan6,0" >> /tmp/wifiunion-uploads/ap_decision_$2.txt
#echo "chan11,0" >> /tmp/wifiunion-uploads/ap_decision_$2.txt

#echo "chan1,0" > /tmp/wifiunion-uploads/client_decision_$2.txt
#echo "chan6,0" >> /tmp/wifiunion-uploads/client_decision_$2.txt
#echo "chan11,0" >> /tmp/wifiunion-uploads/client_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/au_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/au_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/au_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/wing_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/wing_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/wing_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/dmac_50th_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/dmac_50th_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/dmac_50th_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/dmac_90th_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/dmac_90th_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/dmac_90th_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/dmac_avg_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/dmac_avg_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/dmac_avg_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/dmaci_avg_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/dmaci_avg_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/dmaci_avg_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/dmaci_50th_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/dmaci_50th_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/dmaci_50th_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/dmaci_90th_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/dmaci_90th_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/dmaci_90th_decision_$2.txt

#echo "chan1,0" > /tmp/wifiunion-uploads/decisiontree_decision_$2.txt
#echo "chan6,0" >> /tmp/wifiunion-uploads/decisiontree_decision_$2.txt
#echo "chan11,0" >> /tmp/wifiunion-uploads/decisiontree_decision_$2.txt

before_exec_time=`date '+%s'`

while true
do
#	exec_time=`date '+%s'`
#	echo "[$exec_time]: I will change $type to Channel:1"
#	uci set wireless.$type.channel=1
#	uci commit
#	hostapd_cli chan_switch 10 2412

#	echo '0' > /tmp/wifiunion-uploads/$mac/wlan0_slow
#	for i in `seq 1 $roundnum`
#	do
#		echo '' > /tmp/wifiunion-uploads/$mac/wlan0_channel
#		echo '' > /tmp/wifiunion-uploads/$mac/wlan0_station
#		sleep $gap_time
#	#	echo "round $i"
#		/lib/pch/decisiontree.sh
#		echo "round $i"
		
#	done

#	SLOW=`cat /tmp/wifiunion-uploads/$mac/wlan0_slow | grep -o "[-0-9]*"`
#	slowratio=`expr $SLOW "*" 100 "/" $roundnum`
#	sed -i "1s/.*/chan1,$(echo $slowratio)/" /tmp/wifiunion-uploads/decisiontree_decision_$2.txt


#	exec_time=`date '+%s'`
#	echo "[$exec_time]: I will change $type to Channel:6"
#	uci set wireless.$type.channel=6
#	uci commit
#	hostapd_cli chan_switch 10 2437

#	echo '0' > /tmp/wifiunion-uploads/$mac/wlan0_slow
#	for i in `seq 1 $roundnum`
#	do
#		echo '' > /tmp/wifiunion-uploads/$mac/wlan0_channel
#		echo '' > /tmp/wifiunion-uploads/$mac/wlan0_station
#		sleep $gap_time
#		/lib/pch/decisiontree.sh
#	done
#
#	SLOW=`cat /tmp/wifiunion-uploads/$mac/wlan0_slow | grep -o "[-0-9]*"`
#	slowratio=`expr $SLOW "*" 100 "/" $roundnum`
#	sed -i "2s/.*/chan6,$(echo $slowratio)/" /tmp/wifiunion-uploads/decisiontree_decision_$2.txt
#
	exec_time=`date '+%s'`
	echo "[$exec_time]: I will change $type to Channel:11"
	uci set wireless.$type.channel=11
	uci commit
	hostapd_cli chan_switch 10 2462

	echo '0' > /tmp/wifiunion-uploads/$mac/wlan0_slow
	for i in `seq 1 $roundnum`
	do
		echo '' > /tmp/wifiunion-uploads/$mac/wlan0_channel
		echo '' > /tmp/wifiunion-uploads/$mac/wlan0_station
		sleep $gap_time
		/lib/pch/decisiontree.sh
	done

	SLOW=`cat /tmp/wifiunion-uploads/$mac/wlan0_slow | grep -o "[-0-9]*"`
	slowratio=`expr $SLOW "*" 100 "/" $roundnum`
	sed -i "3s/.*/chan11,$(echo $slowratio)/" /tmp/wifiunion-uploads/decisiontree_decision_$2.txt


	slowratio1=`cat /tmp/wifiunion-uploads/decisiontree_decision_$2.txt | grep chan1, | awk -F ',' '{print $2}'`
	echo "channel 1 slowratio1: $slowratio1"
	slowratio6=`cat /tmp/wifiunion-uploads/decisiontree_decision_$2.txt | grep chan6 | awk -F ',' '{print $2}'`
	echo "channel 6 slowratio6: $slowratio6"
	slowratio11=`cat /tmp/wifiunion-uploads/decisiontree_decision_$2.txt | grep chan11 | awk -F ',' '{print $2}'`
	echo "channel 11 slowratio11: $slowratio11"

	chan=0
    if [ $slowratio1 -lt $slowratio6 ]
    then
        slowratio=$slowratio1
        chan=1
    else
        slowratio=$slowratio6
        chan=6
    fi

    if [ $slowratio11 -lt $slowratio ]
    then
        slowratio=$dmac_avg11
        chan=11
    fi

	
	exec_time=`date '+%s'`
	echo "[$exec_time]: I will change $type to Channel:$chan"	
	uci set wireless.$type.channel=$chan
	uci commit
	if [ $chan -eq 1 ]
		then
			hostapd_cli chan_switch 10 2412
	elif [ $chan -eq 6 ]
		then 
			hostapd_cli chan_switch 10 2437
	else
		hostapd_cli chan_switch 10 2462
	fi


	sleep `expr $roundnum \* $gap_time`


done
