mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
/usr/bin/rsync -vzrt  --progress /tmp/wifiunion-uploads/$mac mengyuan@192.168.1.108::wireless_E4F4C6FF8B25 --password-file=/etc/rsync.pass
rm /tmp/wifiunion-uploads/$mac/delay_data/*
rm /tmp/wifiunion-uploads/$mac/inf_data/*
rm /tmp/wifiunion-uploads/$mac/wire_data/*
rm /tmp/wifiunion-uploads/$mac/wifi_data/*
#rm /tmp/wifiunion-uploads/$mac/dmesg_data/*
