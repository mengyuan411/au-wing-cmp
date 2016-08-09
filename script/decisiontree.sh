mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
A1=`head -2 /tmp/wifiunion-uploads/$mac/wlan0_channel | tail -1 | awk -F ',' '{print $2}'`
B1=`head -2 /tmp/wifiunion-uploads/$mac/wlan0_channel | tail -1 | awk -F ',' '{print $3}'`
A2=`tail -1 /tmp/wifiunion-uploads/$mac/wlan0_channel | awk -F ',' '{print $2}'`
B2=`tail -1 /tmp/wifiunion-uploads/$mac/wlan0_channel | awk -F ',' '{print $3}'`
#echo $mac,$A1,$B1,$A2,$B2
tmp1=`expr $B2 - $B1`
tmp2=`expr $A2 - $A1`
#echo $tmp1
if [ $tmp2 -eq 0 ]
then 
	AU=0
else
	AU=`expr $tmp1 "*" 100 "/" $tmp2`
fi
#AU=`expr $tmp1 "*" 100 "/" $tmp2`
#echo $tmp1,$tmp2,$AU
TXPA1=`head -2 /tmp/wifiunion-uploads/$mac/wlan0_station | tail -1 | awk -F ',' '{print $3}'`
TXPA2=`tail -1 /tmp/wifiunion-uploads/$mac/wlan0_station | awk -F ',' '{print $3}'`
TXRE1=`head -2 /tmp/wifiunion-uploads/$mac/wlan0_station | tail -1 | awk -F ',' '{print $4}'`
TXRE2=`tail -1 /tmp/wifiunion-uploads/$mac/wlan0_station | awk -F ',' '{print $4}'`



tmp3=`expr $TXRE2 - $TXRE1`
tmp4=`expr $TXPA2 - $TXPA1`

if [ $tmp4 -eq 0 ]
then 
	RR=0
else
	RR=`expr $tmp3 "*" 100 "/" $tmp4`
fi
#echo $RR
cat /tmp/wifiunion-uploads/$mac/wlan0_station | awk -F ',' 'BEGIN {tpr=0;rpr=0;rssi=0;} {tpr=tpr+$5;rpr=rpr+$6;rssi=rssi+$2;} END {printf("%d,%d,%d",tpr/NR,rpr/NR,rssi/NR)}' > /tmp/wifiunion-uploads/$mac/wlan0_station_tmp

TPR=`cat /tmp/wifiunion-uploads/$mac/wlan0_station_tmp | awk -F ',' '{print $1}'`
RPR=`cat /tmp/wifiunion-uploads/$mac/wlan0_station_tmp | awk -F ',' '{print $2}'`
RSSI=`cat /tmp/wifiunion-uploads/$mac/wlan0_station_tmp | awk -F ',' '{print $3}'`

SLOW=`cat /tmp/wifiunion-uploads/$mac/wlan0_slow | grep -o "[-0-9]*"` 
echo $AU,$RR,$TPR,$RPR,$RSSI
echo $SLOW
if [ $TPR -le 55 ]
then
	if [ $AU -gt 53 ]
	then
		SLOW=`expr $SLOW "+" 1`
	else
		if [ $TPR -le 35 ]
		then
			SLOW=`expr $SLOW "+" 1`
		else
			if [ $RR -gt 52 ]
			then
				SLOW=`expr $SLOW "+" 1`
			fi
		fi
	fi
else
	if [ $AU -le 55 ]
	then
		if [ $RSSI -le -45 -a $AU -gt 42 ]
		then
			SLOW=`expr $SLOW "+" 1`
		fi
		if [ $RSSI -gt -45 -a $TPR -le 68 -a $RR -gt 16 ]
		then
			SLOW=`expr $SLOW "+" 1`
		fi
	else
		if [ $RR -gt 42 ]
		then
			SLOW=`expr $SLOW "+" 1`
		else
			if [ $RPR -le 62 ]
			then
				SLOW=`expr $SLOW "+" 1`
			else
				if [ $TPR -gt 78 ]
				then
					SLOW=`expr $SLOW "+" 1`
				fi
			fi
		fi
	fi
fi

echo $SLOW
echo $SLOW > /tmp/wifiunion-uploads/$mac/wlan0_slow

