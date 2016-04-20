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

	while line:
		if not line.find("ampdu"):
			line = fr.readline()
			continue

		tmp = line.split(',')
		sums = sums + float(tmp[4])
		sumn = sumn + float(tmp[5])
		count = count + 1

		line = fr.readline()

	fr.close()
	fw = open("/tmp/wifiunion-uploads/" + mac + "/numcount.txt",w)
	fw.write(str(sums) + ',' + str(sumn) + ',' + str(count) + '\n')
	fw.close()