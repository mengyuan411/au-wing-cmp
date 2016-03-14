if [ $# -lt 5 ]
then
	echo "Usage: lccs_wing.sh  <wlan_type> <T_run_time> <T_silent_time> <T_silent_thereshold> <continue_flag>"
	echo " "
	echo "       continue_flag : 1|0 if execute the algorithm continuely or
just one round"
	#echo "       algorithm     : ap | client | au | wing"
	echo "       wlan_type     : wlan0 | wlan1"
	echo "       T_run_time    : T_run=60 means changing channel every 60s"
	echo "       T_silent_time : T_silent=30 means even after T_run_time, we have to find the "
	echo "                                   relative silent time to adjuct the channel"
	echo "       T_silent      : T_silent=0 means if wap sends less than 0 bytes "
	echo "                                    in $prob_intervals interverl, then flag this $prob_interval seconds as siltent"

	exit 1
fi

mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
echo $mac



a=0
b=1

dmesg -c 
while rp=1
do
	tmp=`dmesg -c | grep 2.4GHz | awk '{print $NR;}'`
	
	if [ $tmp -ne $a ]
	then
		echo " the experiment begins"
		break
	fi
done
Ts=`date '+%s'`
echo $Ts

/lib/pch/lccs_ex2_daemon.sh au $1 $2 $3 $4 $5 > /tmp/wifiunion-uploads/$mac/lccs_$Ts.log

