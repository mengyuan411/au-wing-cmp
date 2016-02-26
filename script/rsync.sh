mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
/usr/bin/rsync -vzrt  --progress /tmp/wifiunion-uploads/$mac pch@166.111.9.242::pch --password-file=/etc/rsync.pass
rm /tmp/wifiunion-uploads/$mac/delay_data/*
rm /tmp/wifiunion-uploads/$mac/inf_data/*
rm /tmp/wifiunion-uploads/$mac/wire_data/*
rm /tmp/wifiunion-uploads/$mac/wifi_data/*
rm /tmp/wifiunion-uploads/$mac/dmesg_data/*
