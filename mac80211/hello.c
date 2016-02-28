#include <net/ieee80211_radiotap.h>
#include <linux/ieee80211.h>
#include "hello.h"
//#include <time.h>
#define bool int
#define true 1
#define false 0
int t_hello = 0;
int CONST_TIME[WLAN_NUM]={200,212};
struct packet_info store[WLAN_NUM][HOLD_TIME] = {0};
struct packet_info backup_store[WLAN_NUM][HOLD_TIME] = {0};
int current_index[WLAN_NUM] = {0} ;
int previous_is_ampdu[WLAN_NUM] = {0};
struct inf_info cs[WLAN_NUM][CS_NUMBER] = {0}; /* used to store cs info in time gamma */
struct inf_info lccs_client[WLAN_NUM][CS_NUMBER] = {0};
struct summary_info summary[WLAN_NUM]= {0};
struct packet_info last_p[WLAN_NUM]={0};
struct packet_info ppp[WLAN_NUM]= {0};
struct timespec  ht[WLAN_NUM] = {0};
struct timespec lasttw_for_retry[WLAN_NUM] = {0};
struct timespec  inf_start_timestamp = {0};
struct timespec  inf_end_timestamp  = {0};
struct mpdu ampdu[WLAN_NUM]={0};
unsigned char apmac[WLAN_NUM][MAC_LEN]={0};

/* rate in 100kbps */
int wap_type(char ifname[]){
	if( ifname[0]=='w' && ifname[4]=='0')
		return W2G; //wlan0
	else if (ifname[4] == '1')
		return W5G;
	else
		return -1;
}
int mon_type(char ifname[]){
	if( ifname[0]=='m' && ifname[3]=='0')
		return W2G; // mon0
	else if (ifname[3] == '1')
		return W5G;
	else
		return -1;
}
int tolower(char c){
	if (c > 'A'){
		return c-'A'-'a';
	}else{
		return c;
	}
}

int
rate_to_index(int rate)
{
        switch (rate) {
                case 540: return 12;
                case 480: return 11;
                case 360: return 10;
                case 240: return 9;
                case 180: return 8;
                case 120: return 7;
                case 110: return 6;
                case 90: return 5;
                case 60: return 4;
                case 55: return 3;
                case 20: return 2;
                case 10: return 1;
                default: return 0;
        }
}

/* return rate in 100kbps */
int
rate_index_to_rate(unsigned int idx)
{
        switch (idx) {
                case 12: return 540;
                case 11: return 480;
                case 10: return 360;
                case 9: return 240;
                case 8: return 180;
                case 7: return 120;
                case 6: return 110;
                case 5: return 90;
                case 4: return 60;
                case 3: return 55;
                case 2: return 20;
                case 1: return 10;
                default: return 0;
        }
}



/* return rate in 100kbps */
int
mcs_index_to_rate(int mcs, int ht20, int lgi)
{
        /* MCS Index, http://en.wikipedia.org/wiki/IEEE_802.11n-2009#Data_rates */
        switch (mcs) {
                case 0:  return ht20 ? (lgi ? 65 : 72) : (lgi ? 135 : 150);
                case 1:  return ht20 ? (lgi ? 130 : 144) : (lgi ? 270 : 300);
                case 2:  return ht20 ? (lgi ? 195 : 217) : (lgi ? 405 : 450);
                case 3:  return ht20 ? (lgi ? 260 : 289) : (lgi ? 540 : 600);
                case 4:  return ht20 ? (lgi ? 390 : 433) : (lgi ? 810 : 900);
                case 5:  return ht20 ? (lgi ? 520 : 578) : (lgi ? 1080 : 1200);
                case 6:  return ht20 ? (lgi ? 585 : 650) : (lgi ? 1215 : 1350);
                case 7:  return ht20 ? (lgi ? 650 : 722) : (lgi ? 1350 : 1500);
                case 8:  return ht20 ? (lgi ? 130 : 144) : (lgi ? 270 : 300);
                case 9:  return ht20 ? (lgi ? 260 : 289) : (lgi ? 540 : 600);
                case 10: return ht20 ? (lgi ? 390 : 433) : (lgi ? 810 : 900);
                case 11: return ht20 ? (lgi ? 520 : 578) : (lgi ? 1080 : 1200);
                case 12: return ht20 ? (lgi ? 780 : 867) : (lgi ? 1620 : 1800);
                case 13: return ht20 ? (lgi ? 1040 : 1156) : (lgi ? 2160 : 2400);
                case 14: return ht20 ? (lgi ? 1170 : 1300) : (lgi ? 2430 : 2700);
                case 15: return ht20 ? (lgi ? 1300 : 1444) : (lgi ? 2700 : 3000);
                case 16: return ht20 ? (lgi ? 195 : 217) : (lgi ? 405 : 450);
                case 17: return ht20 ? (lgi ? 39 : 433) : (lgi ? 810 : 900);
                case 18: return ht20 ? (lgi ? 585 : 650) : (lgi ? 1215 : 1350);
                case 19: return ht20 ? (lgi ? 78 : 867) : (lgi ? 1620 : 1800);
                case 20: return ht20 ? (lgi ? 1170 : 1300) : (lgi ? 2430 : 2700);
                case 21: return ht20 ? (lgi ? 1560 : 1733) : (lgi ? 3240 : 3600);
                case 22: return ht20 ? (lgi ? 1755 : 1950) : (lgi ? 3645 : 4050);
                case 23: return ht20 ? (lgi ? 1950 : 2167) : (lgi ? 4050 : 4500);
                case 24: return ht20 ? (lgi ? 260 : 288) : (lgi ? 540 : 600);
                case 25: return ht20 ? (lgi ? 520 : 576) : (lgi ? 1080 : 1200);
                case 26: return ht20 ? (lgi ? 780 : 868) : (lgi ? 1620 : 1800);
                case 27: return ht20 ? (lgi ? 1040 : 1156) : (lgi ? 2160 : 2400);
                case 28: return ht20 ? (lgi ? 1560 : 1732) : (lgi ? 3240 : 3600);
                case 29: return ht20 ? (lgi ? 2080 : 2312) : (lgi ? 4320 : 4800);
                case 30: return ht20 ? (lgi ? 2340 : 2600) : (lgi ? 4860 : 5400);
                case 31: return ht20 ? (lgi ? 2600 : 2888) : (lgi ? 5400 : 6000);
        }
        return 0;
}
void
ether_sprintf(unsigned char *mac, char *output)
{
        snprintf(output, sizeof(output), "%02x%02x%02x%02x%02x%02x\0",
                mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
}
void 
pch_print(unsigned char *mac){
	printk(KERN_DEBUG "%02x%02x%02x%02x%02x%02x",mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
}
char *
ether_sprintf_test(unsigned char *mac)
{
	static char output[13]={0};
        snprintf(output, sizeof(output), "%02x%02x%02x%02x%02x%02x\0",
                mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
	return output;
}
char *
ether_sprintf_test2(unsigned char *mac)
{
	static char output2[13]={0};
        snprintf(output2, sizeof(output2), "%02x%02x%02x%02x%02x%02x\0",
                mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
	return output2;
}
char *
ether_sprintf_test3(unsigned char *mac)
{
	static char output3[13]={0};
        snprintf(output3, sizeof(output3), "%02x%02x%02x%02x%02x%02x\0",
                mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
	return output3;
}
char *
ether_sprintf_test4(unsigned char *mac)
{
	static char output4[13]={0};
        snprintf(output4, sizeof(output4), "%02x%02x%02x%02x%02x%02x\0",
                mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
	return output4;
}

char*
ether_sprintf2(unsigned char *mac)
{
        static char etherbuf2[13];
        snprintf(etherbuf2, sizeof(etherbuf2), "%02x%02x%02x%02x%02x%02x",
                mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
        return etherbuf2;
}
int ieee80211_get_hdrlen(u16 fc)
{
        int hdrlen = 24;

        switch (fc & IEEE80211_FCTL_FTYPE) {
        case IEEE80211_FTYPE_DATA:
                if ((fc & IEEE80211_FCTL_FROMDS) && (fc & IEEE80211_FCTL_TODS))
                        hdrlen = 30; /* Addr4 */
                /*
                 * The QoS Control field is two bytes and its presence is
                 * indicated by the IEEE80211_STYPE_QOS_DATA bit. Add 2 to
                 * hdrlen if that bit is set.
                 * This works by masking out the bit and shifting it to
                 * bit position 1 so the result has the value 0 or 2.
                 */
                hdrlen += (fc & IEEE80211_STYPE_QOS_DATA) >> 6;
                break;
        case IEEE80211_FTYPE_CTL:
                /*
                 * ACK and CTS are 10 bytes, all others 16. To see how
                 * to get this condition consider
                 *   subtype mask:   0b0000000011110000 (0x00F0)
                 *   ACK subtype:    0b0000000011010000 (0x00D0)
                 *   CTS subtype:    0b0000000011000000 (0x00C0)
                 *   bits that matter:         ^^^      (0x00E0)
                 *   value of those: 0b0000000011000000 (0x00C0)
                 */
                if ((fc & 0xE0) == 0xC0)
                        hdrlen = 10;
                else
                        hdrlen = 16;
                break;
        }

        return hdrlen;
}
char*
digest_sprintf16(const unsigned char *mac)
{
        char etherbuf[33];
        snprintf(etherbuf, sizeof(etherbuf), "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],mac[6]
                ,mac[7], mac[8], mac[9], mac[10], mac[11], mac[12],mac[13]
                ,mac[14], mac[15]);
        return etherbuf;
}
char*
digest_sprintf30(const unsigned char *mac)
{
        char etherbuf[61];
        snprintf(etherbuf, sizeof(etherbuf), "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],mac[6]
                ,mac[7], mac[8], mac[9], mac[10], mac[11], mac[12],mac[13]
                ,mac[14], mac[15], mac[16], mac[17], mac[18], mac[19]
                ,mac[20], mac[21], mac[22], mac[23], mac[24], mac[25]
                ,mac[26], mac[27], mac[28], mac[29]);
        return etherbuf;
}

int str_equal(char *s1,char *s2,int len){
        int i ;
        for (i = 0; i < len ; i++)
        {
                if( tolower(s1[i]) != tolower(s2[i]) )
                        return 0;
        }
        return 1;
}

/*
To judge whether the current packet are broadcast, cts, ack or control packet(\gamma)
*/
bool control_address(char mac1[13]){
 	if (str_equal(mac_zero,mac1,2*MAC_LEN) == 1)
                return true;
 	if (str_equal(mac_FFFF,mac1,2*MAC_LEN) == 1)
                return true;
 	if (str_equal(mac_ffff,mac1,2*MAC_LEN) == 1)
                return true;
        return false;
}
/*
To check whether the current packet is in the cs list(\gamma)
*/
bool matched(char src[13], char dst[13], char  mac1[13],char mac2[13],int t){
	if ( (str_equal(mac_zero,mac1,2*MAC_LEN) == 1) &&
           (str_equal(mac_zero,mac2,2*MAC_LEN) == 1) )
                return false;    // not vavid data
	if ((control_address(mac1) == 1) &&
	   (  (str_equal(mac2,src,2*MAC_LEN) == 1)||(str_equal(mac2,dst,2*MAC_LEN) == 1) ))
	{
		return true;
	}
	if ((control_address(mac2) == 1) &&
	   (  (str_equal(mac1,src,2*MAC_LEN) == 1)||(str_equal(mac1,dst,2*MAC_LEN) == 1) ))
	{
		return true;
	}
	
	
	if ( (str_equal(mac1,src,2*MAC_LEN) == 1) &&
           (str_equal(mac2,dst,2*MAC_LEN) == 1) )
	{
		return true;
	}
        if ( (str_equal(mac1,dst,2*MAC_LEN) == 1) &&
           (str_equal(mac2,src,2*MAC_LEN) == 1) )
	{
		return true;
	}
        return false;
}
/*
Insert a packet to the carrier sense or hidden teriminal list
*/
void update_list_lccs( unsigned char mac1[6], unsigned char mac2[6],struct timespec  value,int t){
	struct timespec tmp1 = {0};
	if(timespec_compare(&value,&tmp1)<0){
		printk(KERN_DEBUG "[warning]There exists negtive dmac!\n");
	}
	int i;
	struct inf_info * tmp;
	for(i=0;i<CS_NUMBER;i++){
                tmp = (struct inf_info *)&lccs_client[t][i];
		if( (tmp->value.tv_nsec != 0) && 
                    (matched(ether_sprintf_test3(tmp->wlan_src),ether_sprintf_test4(tmp->wlan_dst),ether_sprintf_test(mac1),ether_sprintf_test2(mac2),t) == true) ){
			tmp->value = timespec_add(tmp->value,value);
			return;
                }
        }
        // there is no match!!
        for(i=0;i<CS_NUMBER;i++)
        {
                tmp = (struct inf_info *)&lccs_client[t][i];
                if( (lccs_client[t][i].value.tv_nsec == 0 ) && (control_address(ether_sprintf_test(mac1))== 0)&& (control_address(ether_sprintf_test2(mac2))== 0))
                {
                        memcpy(lccs_client[t][i].wlan_src,mac1,MAC_LEN);
                        memcpy(lccs_client[t][i].wlan_dst,mac2,MAC_LEN);
                        lccs_client[t][i].value = value;
			summary[t].inf_num = summary[t].inf_num + 2;
                        return; 
                }
        }
}
/*
Insert a packet to the carrier sense or hidden teriminal list
*/
void update_list( unsigned char mac1[6], unsigned char mac2[6],struct timespec  value,int t){
	struct timespec tmp1 = {0};
	if(timespec_compare(&value,&tmp1)<0){
		printk(KERN_DEBUG "[warning]There exists negtive dmac!\n");
	}
	int i;
	struct inf_info * tmp;
	for(i=0;i<CS_NUMBER;i++){
                tmp = (struct inf_info *)&cs[t][i];
		if( (tmp->value.tv_nsec != 0) && 
                    (matched(ether_sprintf_test3(tmp->wlan_src),ether_sprintf_test4(tmp->wlan_dst),ether_sprintf_test(mac1),ether_sprintf_test2(mac2),t) == true) ){
                       tmp->value = timespec_add(tmp->value,value);
			return;
                }
        }
        // there is no match!!
        for(i=0;i<CS_NUMBER;i++)
        {
                tmp = (struct inf_info *)&cs[t][i];
                if( (cs[t][i].value.tv_nsec == 0 ) && (control_address(ether_sprintf_test(mac1))== 0)&& (control_address(ether_sprintf_test2(mac2))== 0))
                {
                        memcpy(cs[t][i].wlan_src,mac1,MAC_LEN);
                        memcpy(cs[t][i].wlan_dst,mac2,MAC_LEN);
                        cs[t][i].value = value;
                        return; 
                }
        }
}
static void print_summary(int t){
        printk(KERN_EMERG "\n%ld.%ld->%ld.%ld\n",inf_start_timestamp.tv_sec,inf_start_timestamp.tv_nsec,inf_end_timestamp.tv_sec,inf_end_timestamp.tv_nsec);
        printk(KERN_EMERG "interferes          =%d\n",summary[t].inf_num);
        printk(KERN_EMERG "mine_packets        =%d\n",summary[t].mine_packets);
        printk(KERN_EMERG "inf_packets         =%d\n",summary[t].inf_packets);
        printk(KERN_EMERG "overall_tx_airtime  =%ld s\n",summary[t].overall_extra_time.tv_sec);
        printk(KERN_EMERG "overall_tx_airtime  =%ld ns\n",summary[t].overall_extra_time.tv_nsec);
        printk(KERN_EMERG "overall_busywait    =%ld s\n",summary[t].overall_busywait.tv_sec);
        printk(KERN_EMERG "overall_busywait    =%ld ns\n",summary[t].overall_busywait.tv_nsec);
        printk(KERN_EMERG "mine bytes          =%d Bytes\n",summary[t].mine_bytes);
        printk(KERN_EMERG "mine_throughput     =%d KB/s\n",(int)summary[t].mine_bytes/(int)(FREQUENT_UPDATE_PERIOD_SECONDS*1000));
        printk(KERN_EMERG "inf_throughput      =%d KB/s\n",(int)summary[t].inf_bytes/(int)(FREQUENT_UPDATE_PERIOD_SECONDS*1000));
        printk(KERN_EMERG "sniffer_throughput  =%d KB/s\n",(int)summary[t].sniffer_bytes/(int)(FREQUENT_UPDATE_PERIOD_SECONDS*1000));
        printk(KERN_EMERG "----------------------------------\n");
}
static void reset_summary(int t){
        summary[t].mine_bytes = 0;
        summary[t].mine_packets = 0;
        summary[t].inf_bytes = 0;
        summary[t].inf_packets = 0;
        summary[t].inf_num =0;
        summary[t].overall_busywait.tv_sec = 0;
        summary[t].overall_busywait.tv_nsec = 0;
        summary[t].overall_extra_time.tv_sec = 0;
        summary[t].overall_extra_time.tv_nsec = 0;
        summary[t].rate_adaption_time.tv_sec = 0;
        summary[t].rate_adaption_time.tv_nsec = 0;
        summary[t].sniffer_bytes = 0;
        summary[t].wing = 0;
}
int timespec_div(struct timespec nume, struct timespec deno){
	unsigned long tmp1= (unsigned long)(nume.tv_sec*1000000)+(unsigned long)(nume.tv_nsec/1000);
	unsigned long tmp2= (unsigned long)(deno.tv_sec*1000000)+(unsigned long)(deno.tv_nsec/1000);
	return (int)((tmp1*1000)/tmp2);
	
}
static void print_inf(int t) {
        int j;
	if(t == W2G){
		printk(KERN_DEBUG "\n-------2.4GHz-------\n");
	}else{
		printk(KERN_DEBUG "-------5.0GHz-------\n");
	}	
        printk(KERN_DEBUG "gamma:%ld->%ld\n",inf_start_timestamp.tv_sec,inf_end_timestamp.tv_sec);
        printk(KERN_DEBUG "OVERALL TRANSMITTING TIME:  %ld.%ld\n",summary[t].overall_extra_time.tv_sec,summary[t].overall_extra_time.tv_nsec);
        printk(KERN_DEBUG "OVERALL BUSYWAIT TIME:      %ld.%ld\n",summary[t].overall_busywait.tv_sec,summary[t].overall_busywait.tv_nsec);
        printk(KERN_DEBUG "OVERALL RATEADAPTION TIME:  %ld.%ld\n",summary[t].rate_adaption_time.tv_sec,summary[t].rate_adaption_time.tv_nsec);
        printk(KERN_EMERG "[wAP]%d,[Neighbor]%d, KB/s\n",(int)summary[t].mine_bytes/(int)(FREQUENT_UPDATE_PERIOD_SECONDS*1000),(int)summary[t].sniffer_bytes/(int)(FREQUENT_UPDATE_PERIOD_SECONDS*1000));
	printk(KERN_DEBUG "\nCS:\n");
        for(j = 0 ; j < CS_NUMBER ; j ++){
                if (cs[t][j].value.tv_nsec == 0)
                        break;
                printk(KERN_DEBUG "%s<->%s:%ld second(s) + %ld nanoseconds\n",ether_sprintf_test(cs[t][j].wlan_src),ether_sprintf_test2(cs[t][j].wlan_dst),cs[t][j].value.tv_sec,cs[t][j].value.tv_nsec);
        }

        printk(KERN_DEBUG "\nHT:%ld second(s) + %ld nanoseconds\n",ht[t].tv_sec,ht[t].tv_nsec);
	printk(KERN_DEBUG "Station:%d\n",summary[t].inf_num);
	int inf = timespec_div(timespec_add(summary[t].overall_busywait,ht[t]),summary[t].overall_extra_time);
	printk(KERN_DEBUG "Wing-summary:%d\n",inf);
	int wing_cs_avg = summary[t].wing/summary[t].mine_packets;
	int wing_ht = timespec_div(ht[t],summary[t].overall_extra_time);
	printk(KERN_DEBUG "Wing-average:%d\n",(wing_cs_avg+wing_ht)/2);
	int delay = (summary[t].overall_extra_time.tv_sec*1000+summary[t].overall_extra_time.tv_nsec/1000000)*1000/summary[t].mine_bytes;
	printk(KERN_DEBUG "Delay-summary:%d ms/KB\n",delay);
	int dmac_avg = (summary[t].overall_extra_time.tv_sec*1000+summary[t].overall_extra_time.tv_nsec/1000000)/summary[t].mine_packets;
	printk(KERN_DEBUG "dmac-average-packet:%d \n",dmac_avg);
	if(t == W5G){
		printk(KERN_DEBUG "-------WING_ENDS-------\n");
	}
	//checkpoint
	struct timespec tmp1,tmp2 ={0};
	tmp1 = timespec_add(summary[t].overall_busywait,ht[t]); 
	if( timespec_compare(&tmp1, &summary[t].overall_extra_time) > 0){
		printk(KERN_DEBUG "Interference exceed 100%%\n");
	}

}
void clear_timespec(struct timespec * test){
	test->tv_sec = 0;
	test->tv_nsec = 0;
}
void copy_timespec(struct timespec * dst, struct timespec * src){
	dst->tv_sec = src->tv_sec;
	dst->tv_nsec = src->tv_nsec;
}
struct timespec cal_transmit_time(int len, int rate){
	struct timespec trans= {0};
	unsigned long  trans_tmp = 0;
	//checkpoint
	if (rate == 0){
		return trans;
	}
	trans_tmp = (unsigned long)len*8*10*1000/(unsigned long)rate; // nano seconds
	trans.tv_sec  = trans_tmp/1000000000;
	trans.tv_nsec = (long int)(trans_tmp%1000000000);
	return trans;
}
struct timespec cal_dmaci_ampdu(int t){
	struct timespec transmit={0},tmp1={0},tmp2={0},difs={0},dmaci={0};
	ampdu[t].th = ampdu[t].tw;
	if (timespec_compare(&ampdu[t].th,&ampdu[t].last_te)<0){
		ampdu[t].th=ampdu[t].last_te;
	}
	transmit = cal_transmit_time(ampdu[t].len*ampdu[t].num,ampdu[t].rate);
        difs.tv_sec =0;
	difs.tv_nsec = CONST_TIME[t]*1000;
	tmp1 = timespec_sub(ampdu[t].te,ampdu[t].th);
	tmp2 = timespec_sub(tmp1,transmit);
	dmaci = timespec_sub(tmp2,difs);
	struct timespec ts_tmp;
	getnstimeofday(&ts_tmp);

	//checkpoint
	if (dmaci.tv_sec < 0 || dmaci.tv_nsec < 0){
		dmaci.tv_sec = 0;
		dmaci.tv_nsec = 0;
	}
	return dmaci;
}

void update_summary_cs(struct timespec dmaci,int len,int num,int t){ // t is the type of wifi bands
	struct timespec tmp1={0};
	copy_timespec(&tmp1,&summary[t].overall_busywait);
	summary[t].overall_busywait = timespec_add(tmp1,dmaci);
        summary[t].mine_packets = summary[t].mine_packets + num;
        summary[t].mine_bytes = summary[t].mine_bytes + len;
}
void divide_inf(struct packet_info sniffer[],struct timespec th, struct timespec te, struct timespec dmaci,int retry,int ampdu_type,int t){
        struct timespec tr={0},busywait={0},overall_busywait={0},inf={0},tmp1={0},tmp2={0};
        int j,jump,flag=0;
	int bj,ej = -1;
        //first round
	jump = 0;
	j = current_index[t];
	for (;; j=(j-1+HOLD_TIME)%HOLD_TIME){
		jump = jump + 1;
		if (jump == HOLD_TIME){
			break; 
		}
		clear_timespec(&tr);
                tr = sniffer[j].te;
                if ((timespec_compare(&tr,&th)>0) && (timespec_compare(&tr ,&te)<0)){
			if (flag == 0){
				bj = j;
				flag = 1;
			}
			ej = j;
			clear_timespec(&busywait);
			busywait = cal_transmit_time(sniffer[j].len,sniffer[j].phy_rate);
                        if (retry == 0){
                                overall_busywait = timespec_add(overall_busywait ,busywait);
                        }
                        summary[t].inf_packets = summary[t].inf_packets + 1;
                        summary[t].inf_bytes = summary[t].inf_bytes + sniffer[j].len;
                }
                if ( timespec_compare(&tr,&th)<0){
                        break;
                }
        }
        //second round
	jump = 0;
        for (j =current_index[t];;  j=(j-1+HOLD_TIME)%HOLD_TIME){
                jump = jump +1;
		if (jump == HOLD_TIME){
			break;
		}
		clear_timespec(&tr);
		tr=sniffer[j].te;

                if ((timespec_compare(&tr,&th)>0) && (timespec_compare(&tr ,&te)<0)){
			clear_timespec(&busywait);
			busywait = cal_transmit_time(sniffer[j].len,sniffer[j].phy_rate);
                        int ratio = 100*(busywait.tv_sec*1000000000+busywait.tv_nsec)/(overall_busywait.tv_sec*1000000000+overall_busywait.tv_nsec);
			clear_timespec(&inf);
			inf.tv_sec = dmaci.tv_sec*ratio/100;
			inf.tv_nsec = dmaci.tv_nsec*ratio/100;
			//checkpoint
			if (inf.tv_sec < 0 || inf.tv_nsec < 0){
				inf.tv_sec = 0;
				inf.tv_nsec =0;
			} 
                        if ( retry == 0){
                                update_list(sniffer[j].wlan_src,sniffer[j].wlan_dst,inf,t);
                        }
                }
                if ( timespec_compare(&tr,&th)<0){
                        break;
                }
        }
	
}
void check_print(struct packet_info *p,int t){
        copy_timespec(&inf_end_timestamp,&p->te);
        //printf("start time is %f, end time is %f\n",inf_start_timestamp,inf_end_timestamp);
        if (timespec_sub(inf_end_timestamp,inf_start_timestamp).tv_sec > FREQUENT_UPDATE_PERIOD_SECONDS)
        {
                //print out
                print_inf(W2G);
                print_inf(W5G);
		//print_summary();
		memset(cs,0,sizeof(cs));
                memset(lccs_client,0,sizeof(lccs_client));
		ht[0].tv_sec = 0;
		ht[0].tv_nsec = 0;
                ht[1].tv_sec = 0;
		ht[1].tv_nsec = 0;
		reset_summary(W2G);
		reset_summary(W5G);
                copy_timespec(&inf_start_timestamp,&inf_end_timestamp);
        }
}
void backup_sniffer_packet(struct timespec tw, struct timespec te, int ampdu_type,int t){
        struct timespec tr;
	int j = 0;
        //first round
        int jump = 0;
	for (j =current_index[t];; j=(j-1+HOLD_TIME)%HOLD_TIME){
		jump = jump + 1;
		if (jump == HOLD_TIME){
			break; 
		}
		clear_timespec(&tr);
                tr = store[t][j].te;
                if ((timespec_compare(&tr,&tw)>0) && (timespec_compare(&tr ,&te)<0)){
			backup_store[t][j] = store[t][j];
		}
	}
}
void update_summary_ht(struct timespec dmaci,int len, int num, int t){
	ht[t]= timespec_add(ht[t],dmaci);
        summary[t].mine_packets = summary[t].mine_packets + num;
        summary[t].mine_bytes = summary[t].mine_bytes + len;
}
void update_ht_transmit(int len, int rate,  int t){
	struct timespec tmp;
	tmp = cal_transmit_time(len,rate);
	ht[t]= timespec_add(ht[t],tmp);
}

int cal_inf(struct packet_info * p){
        int t; // type of bands
	t = wap_type(p->dev_name);
	if(t == -1){
		printk(KERN_DEBUG "[warning]wAP dosen't have this kind of interface!\n");	
		return;
	}
	if(p->phy_rate == 0 && p->ampdu != 2){
		printk(KERN_DEBUG "[warning]There is one packet whose phyrate == 0!\n");	
    		memcpy(&last_p[t],p,sizeof(last_p[t]));// update last p
       		previous_is_ampdu[t] = p->ampdu; 
		return;
	}
	
	struct timespec th={0},transmit={0},dmaci={0},tmp1={0},tmp2={0},difs={0},tr={0};
	if (previous_is_ampdu[t] != 0){
		if (p->ampdu != 2){
			dmaci = cal_dmaci_ampdu(t);
                	if (ampdu[t].retry > 0){ // all packets are retried packets
				update_summary_ht(dmaci,ampdu[t].len*ampdu[t].num,ampdu[t].num,t);
			}else{
				divide_inf(backup_store[t],ampdu[t].th,ampdu[t].te,dmaci,0,1,t);
				update_summary_cs(dmaci,ampdu[t].len*ampdu[t].num,1,t);//overall busywait, ampdu regards as one
			}
			clear_timespec(&tmp1);
			tmp1 = timespec_sub(ampdu[t].te,ampdu[t].th);
			summary[t].overall_extra_time = timespec_add(summary[t].overall_extra_time,tmp1);//overall transmit
			summary[t].wing = summary[t].wing + timespec_div(dmaci,tmp1);
			printk(KERN_DEBUG "[ampdu,%ld.%ld]%ld.%ld,%d,%ld.%ld,%ld.%ld,ifindex=%d,%s,num=%d,size=%d,retry=%d\n",ampdu[t].tw.tv_sec,ampdu[t].tw.tv_nsec,ampdu[t].te.tv_sec,ampdu[t].te.tv_nsec,ampdu[t].rate,dmaci.tv_sec,dmaci.tv_nsec,tmp1.tv_sec,tmp1.tv_nsec,ampdu[t].ifindex,ampdu[t].dev_name,ampdu[t].num,ampdu[t].len,ampdu[t].retry);
			//clear the ampdu structure
			memset(&ampdu[t],0,sizeof(ampdu[t]));
		}
	}
	if(p->ampdu == 1){ //first packet of aggregation
		backup_sniffer_packet(p->tw,p->te,1,t);
		ampdu[t].rate = p->phy_rate;
		ampdu[t].ifindex = p->ifindex;
		memcpy(ampdu[t].dev_name,p->dev_name,IFNAMSIZ);
		copy_timespec(&ampdu[t].te,&p->te);
		copy_timespec(&ampdu[t].last_te,&last_p[t].te);
		copy_timespec(&ampdu[t].tw,&p->tw);
		ampdu[t].num = 1;
		ampdu[t].len = p->len;
    		memcpy(&last_p[t],p,sizeof(last_p[t]));// update last p
		check_print(p,t);
                if (p->wlan_retry > 0){
			ampdu[t].retry = p->wlan_retry;
		}
       		previous_is_ampdu[t] = p->ampdu; 
	}else if(p->ampdu==2){ //rest of packets of aggregation
		p->phy_rate = ampdu[t].rate;
		copy_timespec(&ampdu[t].tw,&p->tw);
		ampdu[t].num = ampdu[t].num +  1;
                if ( p->wlan_retry >= 1){
			update_ht_transmit(p->len,p->phy_rate,t);
		}
	}else{
		// non-aggregation packet
		th.tv_sec = p->tw.tv_sec;
		th.tv_nsec = p->tw.tv_nsec;
		if (timespec_compare(&th,&last_p[t].te)<0){
			th=last_p[t].te;
		}
    		
		memcpy(&last_p[t],p,sizeof(last_p[t])); //update previous packet
		if (p->tw.tv_nsec == 0){
       			previous_is_ampdu[t] = p->ampdu;
			return; 
		}
        	transmit = cal_transmit_time(p->len,p->phy_rate);
		difs.tv_sec =0;
		difs.tv_nsec = CONST_TIME[t]*1000;
		tmp1 = timespec_sub(p->te,th);
		tmp2 = timespec_sub(tmp1,transmit);
		dmaci = timespec_sub(tmp2,difs);
		if (dmaci.tv_sec < 0 || dmaci.tv_nsec < 0){
			dmaci.tv_sec = 0;
			dmaci.tv_nsec = 0;
		}
		if(p->wlan_retry == 0){
			update_summary_cs(dmaci,p->len,1,t);
			divide_inf(store[t],th,p->te,dmaci,p->wlan_retry,0,t);
		}else{
			update_summary_ht(dmaci,p->len,1,t);
		}
		summary[t].overall_extra_time = timespec_add(summary[t].overall_extra_time,tmp1);
		summary[t].wing = summary[t].wing + timespec_div(dmaci,tmp1);
		printk(KERN_DEBUG "[unampdu,%ld.%ld]%ld.%ld,%d,%ld.%ld,%ld.%ld,ifindex=%d,%s,num=%d,size=%d,retry=%d\n",p->tw.tv_sec,p->tw.tv_nsec,p->te.tv_sec,p->te.tv_nsec,p->phy_rate,dmaci.tv_sec,dmaci.tv_nsec,tmp1.tv_sec,tmp1.tv_nsec,p->ifindex,p->dev_name,1,p->len,p->wlan_retry);
		
		check_print(p,t);
		previous_is_ampdu[t] = p->ampdu; 
	}

}

