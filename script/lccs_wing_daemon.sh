if [ $# -lt 5 ]
then 
	echo "Usage: lccs_daemon.sh <algorithm> <wlan_type> <T_run_time> <T_silent_time> <T_silent_thereshold>"
	echo " "
	echo "       algorithm     : ap | client | au | wing"
	echo "       wlan_type     : wlan0 | wlan1"
	echo "       T_run_time    : T_run=60 means changing channel every 60s"
	echo "       T_silent_time : T_silent=30 means even after T_run_time, we have to find the "
	echo "                                   relative silent time to adjuct the channel"
	echo "       T_silent      : T_silent=0 means if wap sends less than 0 bytes "
	echo "                                    in $prob_intervals interverl, then flag this $prob_interval seconds as siltent"
	
	exit 1
fi

run_time_threshold=$3
silent_time_threshold=$4
silent_threshold=$5

mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
state=0
state_large=0
pre_bytes=0
prob_interval=10
run_time=`expr 0 - $prob_interval`
silent_time=`expr 0 - $prob_interval`
flag_sent_data=0
flag_time_to_change=0
flag_choose=0


#init every ap to channel 1 at first
type=0
if [ "$2" == "wlan0" ]
then
	type="radio0"
else
	type="radio1"
fi
exec_time=`date '+%s'`
echo "[$exec_time]: I will change $type to Channel:1"
uci set wireless.$type.channel=1
uci commit
wifi

echo "chan1,0" > /tmp/wifiunion-uploads/ap_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/ap_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/ap_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/client_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/client_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/client_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/au_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/au_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/au_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/wing_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/wing_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/wing_decision_$2.txt

while true
do
	run_time=`expr $run_time + $prob_interval`
	if [ $run_time -eq $run_time_threshold ]
	then
		flag_time_to_change=1
		exec_time=`date '+%s'`
		if [ $silent_time -gt $silent_time_threshold ]
		then 
			echo "......"
			echo "silent for $silent_time seconds"
		fi
		echo "[$exec_time]  Start counting down...." 
		silent_time=0
		run_time=0
	fi
	bytes=`ifconfig | grep $2 -A 6 | grep bytes | awk -F "(" '{print $2}' | awk -F ':' '{print $2}'`
	diff=`expr $bytes - $pre_bytes`
	if [ $diff -gt $silent_threshold ] 
	then
		diff=`expr $bytes - $pre_bytes`
		echo "sent $diff bytes"
		flag_sent_data=1
		silent_time=0
	else
		silent_time=`expr $silent_time + $prob_interval`
		if [ $silent_time -le $silent_time_threshold ]
		then 
			echo "silent for $silent_time seconds"
		fi
		if [ \( $flag_sent_data -eq 1 \) -a \( $silent_time -eq $silent_time_threshold \) -a \( $flag_time_to_change -eq 1 \) ]
		then
			#exec_time=`date '+%s'`
			#echo "[$exec_time]  Excuting $1 algorithm"
			if [ $state -eq 2 ]
			then
				state=-1
			else
				state=`expr $state + 1`
			fi
			if [ $state_large -eq 15 ]
			then
				state_large=0
			else
				state_large=`expr $state_large + 1`
			fi

			if [ $flag_choose == 1]
			then
				break
			fi
			case $state_large in
			1)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting ap algorithm"
				/root/pch/lccs_ap.sh 1 $2
				;;	
			2)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting ap algorithm"
				/root/pch/lccs_ap.sh 2 $2
				;;	
			3)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting ap algorithm"
				/root/pch/lccs_ap.sh -1 $2
				;;	
			4)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting client algorithm"
				/root/pch/lccs_client.sh 0 $2
				;;	
			5)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting client algorithm"
				/root/pch/lccs_client.sh 1 $2
				;;	
			6)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting client algorithm"
				/root/pch/lccs_client.sh 2 $2
				;;	
			7)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting client algorithm"
				/root/pch/lccs_client.sh -1 $2
				;;	
			8)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting au algorithm"
				/root/pch/lccs_au.sh 0 $2
				;;	
			9)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting au algorithm"
				/root/pch/lccs_au.sh 1 $2
				;;	
			10)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting au algorithm"
				/root/pch/lccs_au.sh 2 $2
				;;	
			11)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting au algorithm"
				/root/pch/lccs_au.sh -1 $2
				flag_choose=1
				;;	
			12)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting wing algorithm"
				/root/pch/lccs_wing.sh 0 $2
				;;	
			13)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting wing algorithm"
				/root/pch/lccs_wing.sh 1 $2
				;;	
			14)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting wing algorithm"
				/root/pch/lccs_wing.sh 2 $2
				;;	
			15)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting wing algorithm"
				/root/pch/lccs_wing.sh -1 $2
				;;
			esac	
			flag_sent_data=0
			flag_time_to_change=0
			silent_time=0
		fi
	fi
	pre_bytes=$bytes
	sleep $prob_interval
done
