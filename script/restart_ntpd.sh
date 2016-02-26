ntp_pid=`ps | grep ntp | grep -v grep | awk '{print $1}'`
if ps | grep ntp | grep -v grep 
then
	echo "this will restart /etc/init.d/ntpd...."
	kill $ntp_pid
	/etc/init.d/ntpd start
else
	echo "start /etc/init.d/ntpd...."
	/etc/init.d/ntpd start
fi
