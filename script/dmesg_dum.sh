mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
Ts=`date "+%s"`
dmesg -c > /tmp/wifiunion-uploads/$mac/dmesg_data/$Ts
