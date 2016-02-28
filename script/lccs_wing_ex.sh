if [ $# -lt 5 ]
then 
	echo "Usage: lccs_wing.sh <wlan_type> <T_run_time> <T_silent_time> <T_silent_thereshold>"
	echo " "
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
Ts=`date '+%s'`
echo $Ts
#PRO=`ps | grep 'lccs_daemon' | grep -v grep | wc -l`
#if [ $PRO -gt 0 ]
#then
#	echo "lccs already running ...."
#else
	
/root/pch/lccs_wing_daemon.sh au wlan0 $1 $2 $3 > /tmp/wifiunion-uploads/$mac/lccs_$Ts.log
/root/pch/lccs_wing_daemon.sh wing wlan0 $1 $2 $3 >> /tmp/wifiunion-uploads/$mac/lccs_$Ts.log
fi