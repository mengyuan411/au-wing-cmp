mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
echo $mac
Ts=`date '+%s'`
echo $Ts
PRO=`ps | grep 'lccs_daemon' | grep -v grep | wc -l`
if [ $PRO -le 0 ]
then
	/lib/pch/lccs_daemon.sh au wlan0 1800 10 160000 > /tmp/wifiunion-uploads/$mac/lccs_$Ts.log
fi

