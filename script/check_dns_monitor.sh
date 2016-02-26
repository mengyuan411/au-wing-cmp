mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
echo $mac
PRO=`cat /tmp/resolv.conf.auto | grep 114 | wc -l`
if [ $PRO -le 0 ]
then
	echo "nameserver 114.114.114.114" > /tmp/resolv.conf.auto
fi
PRO=`ifconfig | grep mon0 | wc -l`
if [ $PRO -le 0 ]
then
	iw dev wlan0 interface add mon0 type monitor
	ifconfig mon0 up
fi
PRO=`ifconfig | grep mon1 | wc -l`
if [ $PRO -le 0 ]
then
	iw dev wlan1 interface add mon1 type monitor
	ifconfig mon1 up
fi
