if [ $# -lt 3 ]
then 
	echo "Usage: iperf.sh <gap_time> <thoughput> <ip>"
	echo " "
	echo "       gap_time      : gap_time=10 10s busy 10s idle"
	echo "       thoughput     : iperf thoughput "                       
	echo "		 ip 		   : the terminal ip address"
	exit 1
fi


while true
do

	iperf -c $3 -i 1 -b $2 -t $1
	sleep $1
done