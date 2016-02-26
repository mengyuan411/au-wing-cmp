sed -r "s/.*ip6assign.*/        option ip6addr 'fc00:0101:0101::1\/64'/" /etc/config/network  > 1.txt
sed '/wan6/{n;d}' 1.txt  > 2.txt
sed '/wan6/{n;d}' 2.txt  > 1.txt
sed '/wan6/d' 1.txt  > 2.txt
sed '/globals/{n;d}' 2.txt  > 1.txt
sed '/globals/d' 1.txt  > 2.txt
cat 2.txt > /etc/config/network
sed '1,9{;s/REJECT/ACCEPT/g;}' /etc/config/firewall  > 1.txt
cat 1.txt > /etc/config/firewall
rm *.txt
