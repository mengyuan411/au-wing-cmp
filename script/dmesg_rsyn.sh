mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
/usr/bin/rsync -vzrt -zz --progress /tmp/wifiunion-uploads/$mac my@166.111.9.242::wireless_E4F4C6FF8B25 --password-file=/etc/rsync.pass

rm /tmp/wifiunion-uploads/$mac/dmesg_data/*