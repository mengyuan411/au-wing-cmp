mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
echo $mac
mkdir /tmp/wifiunion-uploads
mkdir /tmp/wifiunion-uploads/$mac
mkdir /tmp/wifiunion-uploads/$mac/wifi_data
mkdir /tmp/wifiunion-uploads/$mac/dmesg_data
mkdir /tmp/wifiunion-uploads/$mac/load_data
iw dev wlan0 interface add mon0 type monitor
ifconfig mon0 up
iw dev wlan1 interface add mon1 type monitor
ifconfig mon1 up
echo 123 > /etc/rsync.pass
chmod 600 /etc/rsync.pass

while rp=1
do 
Ts=`date "+%s"`
siq=`top -b -n1 | grep "sirq" | grep -v grep | awk -F ' ' '{print $14}'`
load=`top -b -n1 | grep "Load average" | grep -v grep | awk -F ' ' '{print $3}'`
mem=`free -m | grep Mem | awk -F ' ' '{printf "%0.2f\n",$3/$2}'`
iw dev wlan0 station dump > /tmp/wifiunion-uploads/$mac/wifi_data/wlan0_station_$Ts
iw dev wlan1 station dump > /tmp/wifiunion-uploads/$mac/wifi_data/wlan1_station_$Ts
iw dev wlan0 survey dump > /tmp/wifiunion-uploads/$mac/wifi_data/wlan0_channel_$Ts
iw dev wlan1 survey dump > /tmp/wifiunion-uploads/$mac/wifi_data/wlan1_channel_$Ts
cat /sys/kernel/debug/ieee80211/phy0/ath9k/xmit > /tmp/wifiunion-uploads/$mac/wifi_data/wlan0_tx_$Ts
cat /sys/kernel/debug/ieee80211/phy0/ath9k/recv > /tmp/wifiunion-uploads/$mac/wifi_data/wlan0_rx_$Ts
cat /sys/kernel/debug/ieee80211/phy0/ath9k/queues > /tmp/wifiunion-uploads/$mac/wifi_data/wlan0_q_$Ts
cat /sys/kernel/debug/ieee80211/phy1/ath9k/xmit > /tmp/wifiunion-uploads/$mac/wifi_data/wlan1_tx_$Ts
cat /sys/kernel/debug/ieee80211/phy1/ath9k/recv > /tmp/wifiunion-uploads/$mac/wifi_data/wlan1_rx_$Ts
cat /sys/kernel/debug/ieee80211/phy1/ath9k/queues > /tmp/wifiunion-uploads/$mac/wifi_data/wlan1_q_$Ts
#dmesg -c > /tmp/wifiunion-uploads/$mac/dmesg_data/$Ts
echo $Ts,$siq,$load,$mem > /tmp/wifiunion-uploads/$mac/load_data/heart-beat 


#lccs-wing
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep 5.0GHz -B10 | grep Wing-average | awk -F ':' '{print $2}' >> /tmp/wifiunion-uploads/$mac/wing_wlan0.txt
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep WING_ENDS -B10 | grep Wing-average | awk -F ':' '{print $2}' >> /tmp/wifiunion-uploads/$mac/wing_wlan1.txt
#lccs-dmac-avg
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep 5.0GHz -B10 | grep dmac-average-packet | awk -F ' ' '{print $4}' >> /tmp/wifiunion-uploads/$mac/dmac_avg_wlan0.txt
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep WING_ENDS -B10 | grep dmac-average-packet | awk -F ' ' '{print $4}' >> /tmp/wifiunion-uploads/$mac/dmac_avg_wlan1.txt
#lccs-dmac-50th
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep 5.0GHz -B10 | grep dmac-50th | awk -F ' ' '{print $4}' >> /tmp/wifiunion-uploads/$mac/dmac_50th_wlan0.txt
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep WING_ENDS -B10 | grep dmac-50th | awk -F ' ' '{print $4}' >> /tmp/wifiunion-uploads/$mac/dmac_50th_wlan1.txt
#lccs-dmac-90th
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep 5.0GHz -B10 | grep dmac-90th | awk -F ' ' '{print $4}' >> /tmp/wifiunion-uploads/$mac/dmac_90th_wlan0.txt
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep WING_ENDS -B10 | grep dmac-90th | awk -F ' ' '{print $4}' >> /tmp/wifiunion-uploads/$mac/dmac_90th_wlan1.txt
#lccs-dmaci-avg
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep 5.0GHz -B10 | grep dmaci-average-packet | awk -F ' ' '{print $4}' >> /tmp/wifiunion-uploads/$mac/dmaci_avg_wlan0.txt
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep WING_ENDS -B10 | grep dmaci-average-packet | awk -F ' ' '{print $4}' >> /tmp/wifiunion-uploads/$mac/dmaci_avg_wlan1.txt
#lccs-dmaci-50th
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep 5.0GHz -B10 | grep dmaci-50th | awk -F ' ' '{print $4}' >> /tmp/wifiunion-uploads/$mac/dmaci_50th_wlan0.txt
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep WING_ENDS -B10 | grep dmaci-50th | awk -F ' ' '{print $4}' >> /tmp/wifiunion-uploads/$mac/dmaci_50th_wlan1.txt
#lccs-dmaci-90th
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep 5.0GHz -B10 | grep dmaci-90th | awk -F ' ' '{print $4}' >> /tmp/wifiunion-uploads/$mac/dmaci_90th_wlan0.txt
cat /tmp/wifiunion-uploads/$mac/dmesg_data/* | grep WING_ENDS -B10 | grep dmaci-90th | awk -F ' ' '{print $4}' >> /tmp/wifiunion-uploads/$mac/dmaci_90th_wlan1.txt
#lccs-au
source /lib/pch/kaixin_au.sh wlan0
source /lib/pch/kaixin_au.sh wlan1


source /lib/pch/rsync.sh
done
