#include <linux/time.h>
#include <byteswap.h>
#define le64toh(x) bswap_64(x)
#define le32toh(x) bswap_32(x)
#define le16toh(x) bswap_16(x)

//#define tolower(c)     c - 'A' + 'a'
#define MAC_LEN			6
#define IFNAMSIZ		16
#define HOLD_TIME       500
#define CS_NUMBER       200
//#define CONST_TIME_24   0 //70
//#define CONST_TIME_5    0 //76    //50+16+32Byte*8/24Mbps   
#define NUM_MICROS_PER_SECOND 1e6
#define NUM_NANO_PER_SECOND   1e9
#define WLAN_NUM 2
#define W2G 0
#define W5G 1

#define PHY_FLAG_SHORTPRE	0x0001
#define PHY_FLAG_BADFCS		0x0002
#define PHY_FLAG_A		0x0010
#define PHY_FLAG_B		0x0020
#define PHY_FLAG_G		0x0040
#define PHY_FLAG_MODE_MASK	0x00f0

const static char mac_zero[12] = "000000000000";
const static char mac_FFFF[12] = "FFFFFFFFFFFF";
const static char mac_ffff[12] = "ffffffffffff";

static int FREQUENT_UPDATE_PERIOD_SECONDS = 60;
//int tolower(char c){
//	return c-'A' + 'a';
//}
struct inf_info {
	struct timespec  value;
	int percentage;
	unsigned char wlan_src[MAC_LEN];
	unsigned char wlan_dst[MAC_LEN];
};
struct rate_history_type{
	struct timespec te;
	int phy_rate;
};
struct summary_info{
	int sniffer_bytes;
	int  inf_packets;
	int  mine_packets;
	int inf_bytes;
	int mine_bytes;
	struct timespec  overall_extra_time;
	struct timespec  overall_busywait;
	struct timespec  rate_adaption_time;
	int inf_num;
	int wing;
};
struct packet_info {
	/* general */
	struct timespec tw;
	int len;
	int ampdu;
	/*wlan phy*/
	int phy_signal;
	unsigned int phy_rate;

	/* wlan mac */
	u16		wlan_type;	/* frame control field */
	unsigned char		wlan_src[MAC_LEN];
	unsigned char		wlan_dst[MAC_LEN];
	unsigned int		wlan_retry;
	int phy_noise;
	unsigned int phy_snr;
	unsigned int		wlan_nav;
	struct timespec te;
	int ifindex;
	char dev_name[IFNAMSIZ];
};
struct mpdu{
	struct timespec tw;
	struct timespec th;
	struct timespec te;
	struct timespec last_te;
	int num;
	int len;
	int rate;
	int last_rate;
	int ifindex;
	unsigned char dev_addr[MAC_LEN];
	char dev_name[IFNAMSIZ];
	int retry;
};
/*global struct*/

extern struct packet_info store[WLAN_NUM][HOLD_TIME];
extern struct packet_info backup_store[WLAN_NUM][HOLD_TIME];
extern int current_index[WLAN_NUM] ;
extern int previous_is_ampdu[WLAN_NUM] ;
extern struct inf_info cs[WLAN_NUM][CS_NUMBER]; 
extern struct inf_info lccs_client[WLAN_NUM][CS_NUMBER];
extern struct summary_info summary[WLAN_NUM];
extern struct packet_info last_p[WLAN_NUM];
extern struct packet_info ppp[WLAN_NUM];
extern struct timespec ht[WLAN_NUM];
extern struct timespec inf_end_timestamp;
extern struct timespec inf_start_timestamp;
extern struct mpdu ampdu[WLAN_NUM];
extern int t_hello ;
extern int CONST_TIME[WLAN_NUM];
extern unsigned char apmac[WLAN_NUM][MAC_LEN];
extern struct timespec lasttw_for_retry[WLAN_NUM];
/*declaration of function*/
//extern int parse_80211_header(const unsigned char * buf,  struct packet_info* p);
//extern int parse_radiotap_header(unsigned char * buf,  struct packet_info* p);
int cal_inf(struct packet_info * p);
int mcs_index_to_rate(int mcs,int ht20, int lgi);
int wap_type(char test[]);
int mon_type(char test[]);
int str_equal(char *s1, char *s2,int len);
void update_list_lccs( unsigned char mac1[6], unsigned char mac2[6],struct timespec  value,int t);
void copy_timespec(struct timespec * dst, struct timespec * src);

