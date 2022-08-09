#!/usr/local/bin/python
# coding: utf8
import subprocess
import json

debug = 0
testfile = '/tmp/speedtest.json'


def humanbytes(B):
   'Return the given bytes as a human friendly KB, MB, GB, or TB string'
   B = float(B)
   KB = float(1024)
   MB = float(KB ** 2) # 1,048,576
   GB = float(KB ** 3) # 1,073,741,824
   TB = float(KB ** 4) # 1,099,511,627,776

   if B < KB:
      return '{0} {1}'.format(B,'Bytes' if 0 == B > 1 else 'Byte')
   elif KB <= B < MB:
      return '{0:.2f} Kb/s'.format(B/KB)
   elif MB <= B < GB:
      return '{0:.2f} Mb/s'.format(B/MB)
   elif GB <= B < TB:
      return '{0:.2f} Gb/s'.format(B/GB)
   elif TB <= B:
      return '{0:.2f} Tb/s'.format(B/TB)


if debug:
	from StringIO import StringIO
	import os.path
	if os.path.isfile(testfile):
		SpeedNums = subprocess.check_output(["cat", "/tmp/speedtest.json"])
		speed = StringIO(SpeedNums)
		myspeed = (json.load(speed))
	else:
		print('Please create a test file first: /tmp/speedtest.json')
		exit
else:
	speed = subprocess.check_output(["/usr/local/bin/speedtest", "--json"])
	myspeed = (json.loads(speed))

print ('♻ %.2f   ⬇ %s   ⬆ %s' % (myspeed['ping'], humanbytes(myspeed['download']), humanbytes(myspeed['upload'])))
