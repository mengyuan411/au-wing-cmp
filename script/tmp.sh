mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
echo $mac
PRO=`ps | grep 'dump' | grep -v grep | wc -l`
if [ $PRO -le 0 ]
then
	chmod 777 /lib/pch/dump.sh
	/lib/pch/dump.sh
fi
