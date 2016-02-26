IPPREFIX="http://zhuzhusir.com/downloads"
#cd /lib/pch
#rm restart_ntpd.sh
#wget $IPPREFIX/sh/script/4300/restart_ntpd.sh
sed -i 's/[0-9].openwrt.pool.ntp.org/166.111.8.28/g' /etc/ntp.conf
sed -i 's/[0-9].openwrt.pool.ntp.org/166.111.8.28/g' /etc/config/system
source /lib/pch/restart_ntpd.sh
