import cv2
import imageio
import numpy as np  
import math
import operator
from collections import Counter
import pickle
import random
from util import thirteenNeighbors

# load variables from readVideo.py
rawFrames = pickle.load(open('rawFrames.p','rb'))
clusterId = pickle.load(open('firstIterClusterId.p', 'rb'))
clusterSize = pickle.load(open('firstIterClusterSize.p', 'rb'))
edges = pickle.load(open('firstIterEdges.p','rb'))
processedFrames = []
img = rawFrames[0]
[N, M, d] = img.shape  # dimensions
####TUNE parameter 
enf = 16

def enforceMinRegionSize():
	# iterate all edges again, if the cluster of n1 or cluster of n2 have size < 100, merge
	for weight, n1, n2 in edges:
		if clusterId[n1] == clusterId[n2]:		
			continue
		# if clusterId[n1] or clusterId[n2] is a small cluster, merge this edge 
		if clusterSize[clusterId[n1]] < enf or clusterSize[clusterId[n2]] < enf:	
			# update cluster informations
			clusterSize[clusterId[n1]] += clusterSize[clusterId[n2]]
			del clusterSize[clusterId[n2]]
			toDelete = clusterId[n2]
			for pos, cid in clusterId.iteritems():
				if cid == toDelete:
					clusterId[pos] = clusterId[n1]

print "before enforce:", len(clusterSize)," clusters"
print "enforce mininum region size"
enforceMinRegionSize()
print "after enforce:", len(clusterSize)," clusters"

# 3. assign colors to clusters
print "assigning colors"
colorMap = {}		# clusterId -> RGB	
for v in clusterId.values():
	if v not in colorMap:
		colorMap[v] = [random.randint(0,255),random.randint(0,255),random.randint(0,255)]
pickle.dump(colorMap, open('colormap.p','wb'))

print "storing processed images"
for f in range(len(rawFrames)):
	tmp = [[colorMap[clusterId[((x, y),f)]] for y in range(M)] for x in range(N)]
	processedFrames.append(np.array(tmp, dtype=np.uint8))

# Final: display processed results
for f in range(len(rawFrames)):
	#cv2.imshow('result', processedFrames[f])
	imageio.imwrite('results/'+str(f)+'.png',processedFrames[f])
	if (0xFF & cv2.waitKey(5) == 27) or processedFrames[f].size == 0:
		break

pickle.dump(clusterId, open('EnforcedClusterId.p', 'wb'))

# Memory clean up
clusterId = {}
edges = []
rawFrames = []
clusterSize = []

