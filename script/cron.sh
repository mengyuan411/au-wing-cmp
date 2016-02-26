MAILTO=""
*/1 * * * * source /lib/pch/checkfile.sh
*/1 * * * * source /lib/pch/rsync.sh
*/1 * * * * source /lib/pch/check_dns_monitor.sh
*/1 * * * * /lib/pch/tmp.sh
*/1 * * * * /lib/pch/check_lccs.sh
*/1 * * * * /etc/init.d/isatap start
