# all rights reserved suikaixin@Tsinghua University
INTERVAL="1"

while true
do
#	echo "start"
A1=`iw wlan1 survey dump | grep -F "[in use]" -A5 | grep -e "channel active time" | grep -o "[0-9]*"`  
B1=`iw wlan1 survey dump | grep -F "[in use]" -A5 | grep -e "channel busy time"   | grep -o "[0-9]*"`   
R1=`iw wlan1 survey dump | grep -F "[in use]" -A5 | grep -e "channel receive time"  | grep -o "[0-9]*"`   
T1=`iw wlan1 survey dump | grep -F "[in use]" -A5 | grep -e "channel transmit time" | grep -o "[0-9]*"`  

sleep $INTERVAL 

A2=`iw wlan1 survey dump | grep -F "[in use]" -A5 | grep -e "channel active time" | grep -o "[0-9]*"`  
B2=`iw wlan1 survey dump | grep -F "[in use]" -A5 | grep -e "channel busy time"   | grep -o "[0-9]*"`   
R2=`iw wlan1 survey dump | grep -F "[in use]" -A5 | grep -e "channel receive time"  | grep -o "[0-9]*"`   
T2=`iw wlan1 survey dump | grep -F "[in use]" -A5 | grep -e "channel transmit time" | grep -o "[0-9]*"` 

ALL=`expr $A2 - $A1`

LOAD=`expr $B2 - $B1`

R0=`expr $R2 - $R1`
T0=`expr $T2 - $T1`   
AP=`expr $R0 + $T0` 

IF=`expr $LOAD - $AP`    

LU=`expr $LOAD "*" 100 "/" $ALL`
IU=`expr $IF "*" 100 "/" $ALL`

Tt=`date "+%D %T"`
Ts=`date "+%s"`

echo "$Tt,$IU,$LU,$Ts,$AP,$IF,$LOAD,$ALL" 

#	echo "stop"
done
