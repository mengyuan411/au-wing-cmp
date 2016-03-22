#compare dmac_avg dmac_50th dmac_90th dmaci_avg dmaci_50th dmaci_90th

if [ $# -lt 6 ]
then 
	echo "Usage: lccs_daemon.sh <algorithm> <wlan_type> <T_run_time> <T_silent_time> <T_silent_thereshold> <continue_flag>"
	echo " "
	echo "       algorithm     : au | dmac90 | dmac50 | dmacavg | dmaci90 | dmaci50 | dmaciavg"
	echo "       wlan_type     : wlan0 | wlan1"
	echo "       T_run_time    : T_run=60 means changing channel every 60s"
	echo "       T_silent_time : T_silent=30 means even after T_run_time, we have to find the "
	echo "                                   relative silent time to adjuct the channel"
	echo "       T_silent      : T_silent=0 means if wap sends less than 0 bytes "
	echo "       continue_flag : 1|0 if execute the algorithm continuely or just one round"
	echo "                                    in $prob_intervals interverl, then flag this $prob_interval seconds as siltent"
	
	exit 1
fi

run_time_threshold=$3
silent_time_threshold=$4
silent_threshold=$5

mac=`ifconfig wlan0 | grep HWaddr | awk '{print $5}'|sed 's/://g'`
state=0
case $1 in
'dmacavg') state_large=1
;;
'dmac50') state_large=5
;;
'dmac90') state_large=9
;;
'dmaciavg')state_large=13
;;
'dmaci50')state_large=17
;;
'dmaci90')state_large=21
;;
'au')state_large=25
;;
esac		
state_large=0
pre_bytes=0
prob_interval=10
run_time=`expr 0 - $prob_interval`
silent_time=`expr 0 - $prob_interval`
flag_sent_data=1
flag_time_to_change=0
flag_choose=0  #if continue choose a new channel


#init every ap to channel 1 at first
type=0
if [ "$2" == "wlan0" ]
then
	type="radio0"
else
	type="radio1"
fi
exec_time=`date '+%s'`
echo "[$exec_time]: I will change $type to Channel:1"
uci set wireless.$type.channel=1
uci commit
wifi

#echo "chan1,0" > /tmp/wifiunion-uploads/ap_decision_$2.txt
#echo "chan6,0" >> /tmp/wifiunion-uploads/ap_decision_$2.txt
#echo "chan11,0" >> /tmp/wifiunion-uploads/ap_decision_$2.txt

#echo "chan1,0" > /tmp/wifiunion-uploads/client_decision_$2.txt
#echo "chan6,0" >> /tmp/wifiunion-uploads/client_decision_$2.txt
#echo "chan11,0" >> /tmp/wifiunion-uploads/client_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/au_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/au_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/au_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/wing_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/wing_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/wing_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/dmac_50th_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/dmac_50th_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/dmac_50th_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/dmac_90th_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/dmac_90th_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/dmac_90th_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/dmac_avg_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/dmac_avg_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/dmac_avg_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/dmaci_avg_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/dmaci_avg_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/dmaci_avg_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/dmaci_50th_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/dmaci_50th_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/dmaci_50th_decision_$2.txt

echo "chan1,0" > /tmp/wifiunion-uploads/dmaci_90th_decision_$2.txt
echo "chan6,0" >> /tmp/wifiunion-uploads/dmaci_90th_decision_$2.txt
echo "chan11,0" >> /tmp/wifiunion-uploads/dmaci_90th_decision_$2.txt

before_exec_time=0

while true
do
	run_time=`expr $run_time + $prob_interval`
	if [ $run_time -eq $run_time_threshold ]
	then
		flag_time_to_change=1
		exec_time=`date '+%s'`
		if [ $silent_time -gt $silent_time_threshold ]
		then 
			echo "......"
			echo "silent for $silent_time seconds"
		fi
		echo "[$exec_time]  Start counting down...." 
		silent_time=0
		run_time=0
	fi
	bytes=`ifconfig | grep $2 -A 6 | grep bytes | awk -F "(" '{print $2}' | awk -F ':' '{print $2}'`
	diff=`expr $bytes - $pre_bytes`
	if [ $diff -gt $silent_threshold ] 
	then
		diff=`expr $bytes - $pre_bytes`
		echo "sent $diff bytes"
		flag_sent_data=1
		silent_time=0
	else
		silent_time=`expr $silent_time + $prob_interval`
		if [ $silent_time -le $silent_time_threshold ]
		then 
			echo "silent for $silent_time seconds"
		fi
		if [ \( $flag_sent_data -eq 1 \) -a \( $silent_time -eq $silent_time_threshold \) -a \( $flag_time_to_change -eq 1 \) ]
		then
			#exec_time=`date '+%s'`
			#echo "[$exec_time]  Excuting $1 algorithm"
			if [ $state -eq 2 ]
			then
				state=-1
			else
				state=`expr $state + 1`
			fi
			case $1 in
			'dmacavg') 
				if [ $state_large -eq 4 ]
                        	then
                                	state_large=1
                        	else
                                	state_large=`expr $state_large + 1`
                       		fi
			;;
			'dmac50')
				if [ $state_large -eq 8 ]
                                then
                                        state_large=5
                                else
                                        state_large=`expr $state_large + 1`
				fi

			;;
			'dmac90') 
				if [ $state_large -eq 12 ]
                                then
                                        state_large=9
                                else
                                        state_large=`expr $state_large + 1`
                                fi
			;;
			'dmaciavg')
				if [ $state_large -eq 16 ]
                                then
                                        state_large=13
                                else
                                        state_large=`expr $state_large + 1`
                                fi
			;;
			'dmaci50')
				if [ $state_large -eq 20 ]
                                then
                                        state_large=17
                                else
                                        state_large=`expr $state_large + 1`
                                fi
			;;
			'dmaci90')
				if [ $state_large -eq 24 ]
                                then
                                        state_large=21
                                else
                                        state_large=`expr $state_large + 1`
                                fi
			;;
			'au')
				if [ $state_large -eq 28 ]
                                then
                                        state_large=25
                                else
                                        state_large=`expr $state_large + 1`
                                fi
			;;
			esac
			if [ $state_large -eq 28 ]
			then
				state_large=0
			else
				state_large=`expr $state_large + 1`
			fi

			if [ $flag_choose == 1 ]
			then
				break
			fi
			case $state_large in
			1)
				exec_time=`date '+%s'`
				before_exec_time=$exec_time
				echo "[$exec_time]  Excuting dmac average algorithm"
				/lib/pch/lccs_dmac_avg.sh 0 $2
				;;
			2)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting dmac average algorithm"
				/lib/pch/lccs_dmac_avg.sh 1 $2 $before_exec_time
				before_exec_time=$exec_time
				;;	
			3)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting dmac average algorithm"
				/lib/pch/lccs_dmac_avg.sh 2 $2 $before_exec_time
				before_exec_time=$exec_time
				;;		
			4)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting dmac average algorithm"
				/lib/pch/lccs_dmac_avg.sh -1 $2 $before_exec_time
				before_exec_time=$exec_time
			#	flag_choose=1
				;;	
		#	5)
		#		exec_time=`date '+%s'`
		#		echo "[$exec_time]  Excuting wing algorithm"
		#		/lib/pch/lccs_wing.sh 0 $2
		#		before_exec_time=$exec_time
		#		;;	
		#	6)
		#		exec_time=`date '+%s'`
		#		echo "[$exec_time]  Excuting wing algorithm"
		#		/lib/pch/lccs_wing.sh 1 $2 $before_exec_time
		##		before_exec_time=$exec_time
		#		;;	
		#	7)
		#		exec_time=`date '+%s'`
		#		echo "[$exec_time]  Excuting wing algorithm"
		#		/lib/pch/lccs_wing.sh 2 $2 $before_exec_time
		#		before_exec_time=$exec_time
		#		;;	
		#	8)
		#		exec_time=`date '+%s'`
	#			echo "[$exec_time]  Excuting wing algorithm"
	#			/lib/pch/lccs_wing.sh -1 $2 $before_exec_time
	#			before_exec_time=$exec_time
			#	if [ $6 == 0 ]
			#	then
			#		flag_choose=1
			#	fi
			#	;;	
			5)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmac 50th algorithm"
                                /lib/pch/lccs_dmac_50th.sh 0 $2
                                before_exec_time=$exec_time
				;;
                        6)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmac 50th algorithm"
                                /lib/pch/lccs_dmac_50th.sh 1 $2 $before_exec_time
				before_exec_time=$exec_time
                                ;;
                        7)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmac 50th algorithm"
                                /lib/pch/lccs_dmac_50th.sh 2 $2 $before_exec_time
				before_exec_time=$exec_time
                                ;;
                        8)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmac 50th algorithm"
                                /lib/pch/lccs_dmac_50th.sh -1 $2 $before_exec_time
				before_exec_time=$exec_time
                        #       flag_choose=1
                                ;;
			
			9)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmac 90th algorithm"
                                /lib/pch/lccs_dmac_90th.sh 0 $2
                                before_exec_time=$exec_time
				;;
                        10)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmac 90th algorithm"
                                /lib/pch/lccs_dmac_90th.sh 1 $2 $before_exec_time
				before_exec_time=$exec_time
                                ;;
                        11)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmac 90th algorithm"
                                /lib/pch/lccs_dmac_90th.sh 2 $2 $before_exec_time
				before_exec_time=$exec_time
                                ;;
                        12)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmac 90th algorithm"
                                /lib/pch/lccs_dmac_90th.sh -1 $2 $before_exec_time
				before_exec_time=$exec_time
                        #       flag_choose=1
                                ;;
			13)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmaci average algorithm"
                                /lib/pch/lccs_dmaci_avg.sh 0 $2
                                ;;
                        14)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmaci average algorithm"
                                /lib/pch/lccs_dmaci_avg.sh 1 $2 $before_exec_time
				before_exec_time=$exec_time
                                ;;
                        15)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmaci average algorithm"
                                /lib/pch/lccs_dmaci_avg.sh 2 $2 $before_exec_time
				before_exec_time=$exec_time
                                ;;
                        16)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmaci average algorithm"
                                /lib/pch/lccs_dmaci_avg.sh -1 $2 $before_exec_time
				before_exec_time=$exec_time
                        #       flag_choose=1
                                ;;
			17)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmaci 50th algorithm"
                                /lib/pch/lccs_dmaci_50th.sh 0 $2
                                before_exec_time=$exec_time
				;;
                        18)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmaci 50th algorithm"
                                /lib/pch/lccs_dmaci_50th.sh 1 $2 $before_exec_time
				before_exec_time=$exec_time
                                ;;
                        19)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmaci 50th algorithm"
                                /lib/pch/lccs_dmaci_50th.sh 2 $2 $before_exec_time
				before_exec_time=$exec_time
                                ;;
                        20)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmaci 50th algorithm"
                                /lib/pch/lccs_dmaci_50th.sh -1 $2 $before_exec_time
				before_exec_time=$exec_time
                        #       flag_choose=1
                                ;;
			21)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmaci 90th algorithm"
                                /lib/pch/lccs_dmaci_90th.sh 0 $2
                                before_exec_time=$exec_time
				;;
                        22)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmaci 90th algorithm"
                                /lib/pch/lccs_dmaci_90th.sh 1 $2 $before_exec_time
				before_exec_time=$exec_time
                                ;;
                        23)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmaci 90th algorithm"
                                /lib/pch/lccs_dmaci_90th.sh 2 $2 $before_exec_time
				before_exec_time=$exec_time
                                ;;
                        24)
                                exec_time=`date '+%s'`
                                echo "[$exec_time]  Excuting dmaci 90th algorithm"
                                /lib/pch/lccs_dmaci_90th.sh -1 $2 $before_exec_time
				before_exec_time=$exec_time
                        #       flag_choose=1
			#	if [ $6 == 0 ]
                         #       then
                          #              flag_choose=1
                           #     fi
                                ;;

			25)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting au algorithm"
				/lib/pch/lccs_au.sh 0 $2
				;;
			26)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting au algorithm"
				/lib/pch/lccs_au.sh 1 $2
				;;	
			27)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting au algorithm"
				/lib/pch/lccs_au.sh 2 $2
				;;		
			28)
				exec_time=`date '+%s'`
				echo "[$exec_time]  Excuting au algorithm"
				/lib/pch/lccs_au.sh -1 $2
			#	flag_choose=1
				 if [ $6 == 0 ]
                                then
                                        flag_choose=1
                                fi
                                ;;
				

			esac	
			flag_sent_data=1
			flag_time_to_change=0
			silent_time=0
		fi
	fi
	pre_bytes=$bytes
	sleep $prob_interval
done
