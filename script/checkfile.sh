rm on-off.config
mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
IPPREFIX="http://zhuzhusir.com/downloads"
wget $IPPREFIX/sh/script/4300/on-off.config
if cat on-off.config | grep $mac; then
	rm one-click.sh
	wget $IPPREFIX/sh/script/4300/one-click.sh
	source one-click.sh
	rm one-click.sh
fi
rm on-off.config
