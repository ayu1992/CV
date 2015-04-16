import cv2
import numpy
import math
import operator
from collections import Counter
import random

rawFrames = []
processedFrames = []

# read in video file
cam = cv2.VideoCapture("6f.mp4")  
i = 0
while True:
	ret, img = cam.read()
	print i
	i += 1
	if (type(img) == type(None)):
		break
	rawFrames.append(img)

# Begin processing
# First iteration : 17 neighbors
img = rawFrames[0]
[N, M, d] = img.shape  # dimensions

# BUILD LOOKUPs
# initialize clusterId : node ((coordinates), frame) -> cluster
clusterId = {}
cid = 0
for f in range(len(rawFrames)):
	for x in range(N):
		for y in range(M):
			clusterId[((x,y),f)] = cid 	
			cid += 1

# initialize clusterSize : cluster -> number of nodes
clusterSize = Counter([cid for cid in clusterId.itervalues()])

# initialize IntR : cluster -> R value (largest edge weight)
IntR = {n : 0 for n in range(len(clusterId))}
print "0. done building clusters"
# HELPER FUNCTIONS

def twentySixNeighbors(((x,y),frameIndex)):
	# 8 neighbors in same frame
	ret = [((x-1,y-1),frameIndex),((x-1, y),frameIndex),((x-1, y+1),frameIndex),((x,y-1),frameIndex),((x,y+1),frameIndex),((x+1,y-1),frameIndex),((x+1,y),frameIndex),((x+1,y+1),frameIndex)]
	ret = [((s,t),frameIndex) for (s,t) in ret if s >= 0 and s < N and t >= 0 and t < M]

	# 9 neighbors in next frame
	frameIndex += 1
	if frameIndex < len(rawFrames):
		tmp = [((x-1,y-1),frameIndex),((x-1, y),frameIndex),((x,y),frameIndex),((x-1, y+1),frameIndex),((x,y-1),frameIndex),((x,y+1),frameIndex),((x+1,y-1),frameIndex),((x+1,y),frameIndex),((x+1,y+1),frameIndex)]
		ret += [((s,t),frameIndex) for (s,t) in tmp if s >= 0 and s < N and t >= 0 and t < M]
	
	# 9 neighbors in previous frame
	frameIndex -= 2
	if frameIndex >= 0:
		tmp = [((x-1,y-1),frameIndex),((x-1, y),frameIndex),((x,y),frameIndex),((x-1, y+1),frameIndex),((x,y-1),frameIndex),((x,y+1),frameIndex),((x+1,y-1),frameIndex),((x+1,y),frameIndex),((x+1,y+1),frameIndex)]
		ret += [((s,t),frameIndex) for (s,t) in tmp if s >= 0 and s < N and t >= 0 and t < M]
	return ret

def pixelDistance(((x1,y1),f1),((x2,y2),f2)):
	return math.sqrt((int(rawFrames[f1][x1,y1,0])-int(rawFrames[f2][x2,y2,0]))**2 + (int(rawFrames[f1][x1,y1,1])-int(rawFrames[f2][x2,y2,1]))**2 + (int(rawFrames[f1][x1,y1,2])-int(rawFrames[f2][x2,y2,2]))**2)/255.0

# SEGMENTATION ALGORITHM : oversegmentation and merging
tau = 0.02

# 1. sort graph by weight	
print "1. sort graph by weight\n"
edges = []						# (node, node)-> weight w
for node in clusterId:
	neighbors = twentySixNeighbors(node)
	for n in neighbors:
		edges.append((pixelDistance(node,n), node, n))
sorted_edges = sorted(edges)

print "2. iter all edges\n"
# 2. for each region, calculate R with eq (1), tau *= 1.1
for weight, n1, n2 in sorted_edges:
	if clusterId[n1] == clusterId[n2]:
		print "same cluster\n"
		continue
	# if edge weight < both regions then merge
	
	if weight <= (IntR[clusterId[n1]] + tau / clusterSize[clusterId[n1]]) and weight <= (IntR[clusterId[n2]] + tau / clusterSize[clusterId[n2]]):
		print "MERGE!\n"
		# new R of compound region
		IntR[clusterId[n1]] = max(IntR[clusterId[n1]],IntR[clusterId[n2]],weight)
		del IntR[clusterId[n2]]
		# update cluster informations
		clusterSize[clusterId[n1]] += clusterSize[clusterId[n2]]
		del clusterSize[clusterId[n2]]

		toDelete = clusterId[n2]
		for pos, cid in clusterId.iteritems():
			if cid == toDelete:
				clusterId[pos] = clusterId[n1]
''''
# 3. output first iteration
colorMap = {}		# clusterId -> RGB	
for v in clusterId.values():
	if v not in colorMap:
		colorMap[v] = [random.randint(0,255),random.randint(0,255),random.randint(0,255)]

output = [[colorMap[clusterId[(x, y)]] for y in range(M)] for x in range(N)]

processedFrames.append(img)
'''

''''
# process rest of the frames
while True:
    ret, img = cam.read()                      
    if (type(img) == type(None)):
        break
    # display each frame
    cv2.imshow('result', img)
    print ret
    if (0xFF & cv2.waitKey(5) == 27) or img.size == 0:
    	break
'''
cv2.destroyAllWindows()