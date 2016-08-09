# all rights reserved suikaixin@Tsinghua University
mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`

INTERVAL="1"

while true
do
#	echo "start"
A1=`iw wlan0 survey dump | grep -F "[in use]" -A5 | grep -e "channel active time" | grep -o "[0-9]*"`  
B1=`iw wlan0 survey dump | grep -F "[in use]" -A5 | grep -e "channel busy time"   | grep -o "[0-9]*"`   
R1=`iw wlan0 survey dump | grep -F "[in use]" -A5 | grep -e "channel receive time"  | grep -o "[0-9]*"`   
T1=`iw wlan0 survey dump | grep -F "[in use]" -A5 | grep -e "channel transmit time" | grep -o "[0-9]*"`  

Ts=`date "+%s"`

echo "$Ts,$A1,$B1,$R1,$T1" >> /tmp/wifiunion-uploads/$mac/wlan0_channel

RSSI=`iw wlan0 station dump | grep -e "signal avg" | grep -o "[-0-9]*" | head -1`  
TXPA=`iw wlan0 station dump | grep -e "tx packets" | grep -o "[-0-9]*"`   
TXRE=`iw wlan0 station dump | grep -e "tx retries" | grep -o "[-0-9]*"`   
TPR=`iw wlan0 station dump | grep -e "tx bitrate" | grep -o "[.0-9]*" | head -1`
RPR=`iw wlan0 station dump | grep -e "rx bitrate" | grep -o "[.0-9]*" | head -1`  

echo "$Ts,$RSSI,$TXPA,$TXRE,$TPR,$RPR" >> /tmp/wifiunion-uploads/$mac/wlan0_station



sleep $INTERVAL

#	echo "stop"
done