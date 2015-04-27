import cv2
import imageio
import numpy as np  
import math
import operator
from collections import Counter
import pickle
import random
from util import thirteenNeighbors

rawFrames = []
processedFrames = []
edges = []

# read in video file
cam = cv2.VideoCapture("doves_8.mp4")  
i = 0
while i < 16:
	ret, img = cam.read()
	i += 1
	if (type(img) == type(None)):
		break
	#if i%2 == 0:
	print i
	rawFrames.append(img)
img = rawFrames[0]
[N, M, d] = img.shape  # dimensions
# BUILD LOOKUPs
# initialize clusterId : node ((coordinates), frame) -> cluster id
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

def pixelDistance(((x1,y1),f1),((x2,y2),f2)):
	return math.sqrt((int(rawFrames[f1][x1,y1,0])-int(rawFrames[f2][x2,y2,0]))**2 + (int(rawFrames[f1][x1,y1,1])-int(rawFrames[f2][x2,y2,1]))**2 + (int(rawFrames[f1][x1,y1,2])-int(rawFrames[f2][x2,y2,2]))**2)/255.0

def firstIter():
	print "1. sort graph by weight\n"
	for node in clusterId:
		neighbors = thirteenNeighbors(node,N,M,len(rawFrames))
		for n in neighbors:
			edges.append((pixelDistance(node,n), node, n))
	print "sort\n"
	edges.sort()
	print "2. iter all edges\n"
	for weight, n1, n2 in edges:
		if clusterId[n1] == clusterId[n2]:		
			continue
		# if edge weight < both regions then merge
		if weight <= (IntR[clusterId[n1]] + tau / clusterSize[clusterId[n1]]) and weight <= (IntR[clusterId[n2]] + tau / clusterSize[clusterId[n2]]):
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
	print len(edges)


# SEGMENTATION ALGORITHM : oversegmentation and merging
tau = 0.02

# First iteration : over-segmentation
firstIter()

# Dump results from first iteration(deterministics)
pickle.dump(clusterId, open('firstIterClusterId.p', 'wb'))
pickle.dump(clusterSize, open('firstIterClusterSize.p','wb'))
pickle.dump(edges, open('firstIterEdges.p','wb'))
pickle.dump(rawFrames, open('rawFrames.p','wb'))

# Memory clean up
clusterId = {}
edges = []
rawFrames = []
IntR = []
clusterSize = []
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