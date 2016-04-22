mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
echo $mac
PRO=`ps | grep 'dmesg_dum' | grep -v grep | wc -l`
if [ $PRO -le 0 ]
then
        chmod 777 /lib/pch/dmesg_dum.sh
        /lib/pch/dmesg_dum.sh 5 1 
fi
