import sys
import os

if __name__=='__main__':
	filepath = sys.argv[1]
	sums = float(sys.argv[2])
	sumn = float(sys.argv[3])
	count = float(sys.argv[4])
	mac = sys.argv[5]

	fr = open(filepath)
	line = fr.readline()

	alldata = []
	

	while line:
		if not line.find("ampdu"):
			line = fr.readline()
			continue

		tmp = line.split(',')
		single = []
		single.append(float(tmp[4]))
		single.append(float(tmp[5]))
		alldata.append(single)
		

		line = fr.readline()

	alldata.sort()

	lenth = len(alldata)
	sums = sums + alldata[lenth * 9 / 10][0]
	sumn = sumn + alldata[lenth * 9 / 10][1]
	count = count + 1

	fr.close()
	fw = open("/tmp/wifiunion-uploads/" + mac + "/numcount.txt",'w')
	fw.write(str(sums) + ',' + str(sumn) + ',' + str(count) + '\n')
	fw.close()