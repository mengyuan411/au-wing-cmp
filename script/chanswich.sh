gaptime=$1


chan=1
uci set wireless.radio0.channel=$chan
uci commit
hostapd_cli chan_switch 10 2412

sleep $gaptime

while rp==1
do
	if [ $chan -eq 1 ]
	then
		chan=6
		uci set wireless.radio0.channel=$chan
		uci commit
		exec_time=`date '+%s'`
		echo "[$exec_time]: I will change wlan0 to Channel:$chan"
		hostapd_cli chan_switch 10 2437
	elif [ $chan -eq 6 ]
	then
		chan=11
		uci set wireless.radio0.channel=$chan
		uci commit
		exec_time=`date '+%s'`
		echo "[$exec_time]: I will change wlan0 to Channel:$chan"
		hostapd_cli chan_switch 10 2462
	else
		chan=1
		uci set wireless.radio0.channel=$chan
		uci commit
		exec_time=`date '+%s'`
		echo "[$exec_time]: I will change wlan0 to Channel:$chan"
		hostapd_cli chan_switch 10 2412
	fi
	echo $chan

	sleep $gaptime
done
