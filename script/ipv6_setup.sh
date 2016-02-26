# echo ip6tables -t nat -I POSTROUTING -s fc00:101:101::/64 -j MASQUERADE >> /etc/firewall.user
rm /etc/config/radvd
rm /etc/firewall.user
cp /lib/pch/radvd /etc/config/
cp /lib/pch/firewall.user /etc/
cp /lib/pch/isatap /etc/init.d/
chmod +x /etc/init.d/isatap
source /lib/pch/sed_network.sh
/etc/init.d/network restart
sleep 5
/etc/init.d/isatap start
/etc/init.d/isatap enable
/etc/init.d/firewall restart
/etc/init.d/radvd start
/etc/init.d/radvd enable
echo "/etc/init.d/isatap start" > /etc/rc.local
echo "exit(0)" >> /etc/rc.local
