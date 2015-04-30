import cv2
import imageio
import numpy as np  
from numpy import *
import math
import operator
from collections import Counter
import pickle
import video
import random
from util import thirteenNeighbors
rawInput = []
rawFrames = []
processedFrames = []
edges = []

# read in video file
cam = cv2.VideoCapture("doves_8.mp4")  
i = 0
while i < 12:
	ret, img = cam.read()
	i += 1
	if (type(img) == type(None)):
		break
	if i%2 == 0:
		print i
		rawInput.append(img)

# RUN OPTICAL FLOW
print "Run optical flow"
## Generate flow map for all pixels, E.g.: rawFlow(x,y,f) -> a length 16 vector
flow = []
# compute flows for all frame pairs
prev = rawInput[0]
prevgray = cv2.cvtColor(prev, cv2.COLOR_RGB2GRAY)
# if test image
#prevgray = cv2.cvtColor(np.array(prev, dtype=np.uint8), cv2.COLOR_RGB2GRAY)
nextframe = 1

while nextframe <= len(rawInput) - 1:
	# convert color images to grayscale
	nextgray = cv2.cvtColor(rawInput[nextframe], cv2.COLOR_RGB2GRAY)
	# if test image
#	nextgray = cv2.cvtColor(np.array(rawInput[nextframe], dtype=np.uint8), cv2.COLOR_RGB2GRAY)
	# compute flow between two frames
	flow.append(cv2.calcOpticalFlowFarneback(prevgray, nextgray,0.5,1,3,15,3,5,1))
	prevgray = nextgray
	nextframe += 1

# print flow[0].shape # (N, M, 2)
# flow[f][x,y] : [dx dy]
#print "length of rawFlow : ", len(flow)
img = rawInput[0]
[N, M, d] = img.shape
s = []
for f in flow:
	for x in range(N):
		for y in range(M):
			abs_val = math.sqrt(f[x,y][0]**2 + f[x,y][1]**2)
			if abs_val > 10:
				f[x,y] /= math.sqrt(10.0 / abs_val)

pickle.dump(flow, open('rawFlow.p', 'wb'))
flow = []
''''
hist, bins = np.histogram(s, density=True)
'''

# CONVERT TO LAB Color Space
print "convert to Lab space"
for f in rawInput:
	lab = cv2.cvtColor(f, cv2.COLOR_RGB2LAB)
	rawFrames.append(lab / 256.0)

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
	return math.sqrt(((rawFrames[f1][x1,y1,0])-(rawFrames[f2][x2,y2,0]))**2 + ((rawFrames[f1][x1,y1,1])-(rawFrames[f2][x2,y2,1]))**2 + ((rawFrames[f1][x1,y1,2])-(rawFrames[f2][x2,y2,2]))**2)

def firstIter():
	print "1. sort graph by weight\n"
	for node in clusterId:
		neighbors = thirteenNeighbors(node,N,M,len(rawFrames))
		for n in neighbors:
			edges.append((pixelDistance(node,n), node, n))
	print "sort\n"
	edges.sort()
	print max(edges)
	print min(edges)
	merge_cnt = 0
	print "2. iter all edges\n"
	for weight, n1, n2 in edges:
		if clusterId[n1] == clusterId[n2]:		
			continue
		# if edge weight < both regions then merge
		if weight <= (IntR[clusterId[n1]] + tau / clusterSize[clusterId[n1]]) and weight <= (IntR[clusterId[n2]] + tau / clusterSize[clusterId[n2]]):
			merge_cnt += 1
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
	print "merged ",merge_cnt,"clusters"

# SEGMENTATION ALGORITHM : oversegmentation and merging
tau = 0.02

# First iteration : over-segmentation
firstIter()
print len(clusterId)
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