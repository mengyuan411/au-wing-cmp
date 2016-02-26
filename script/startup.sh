mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
source /lib/pch/ipv6_setup.sh
source /lib/pch/ntp.sh
cat /lib/pch/cron.sh > /etc/crontabs/root
/etc/init.d/cron restart
cat /etc/config/wireless | sed "s/OpenWrt/$mac/g" > 1.txt
cat 1.txt > /etc/config/wireless
rm 1.txt
cat /etc/config/dropbear | sed "s/'on'/'off'/g" > 1.txt
cat 1.txt > /etc/config/dropbear
rm 1.txt
/etc/init.d/network restart
