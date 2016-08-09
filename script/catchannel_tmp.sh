PRO=`ps | grep 'catchannel' | grep -v grep | wc -l`
if [ $PRO -le 0 ]
then
        chmod 777 /lib/pch/catchannel.sh
        /lib/pch/catchannel.sh 
fi