mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
/usr/bin/rsync -qzrt -zz --progress /tmp/wifiunion-uploads/$mac/dmesg_data mengyuan@192.168.1.108::dmesg_E4F4C6FF8B25 --password-file=/etc/rsync.pass

rm /tmp/wifiunion-uploads/$mac/dmesg_data/*