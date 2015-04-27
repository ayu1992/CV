import cv2
import imageio
import numpy as np  
import math
import operator
from collections import Counter
import random
import pickle
from util import thirteenNeighbors

###TUNE parameter
hierarchy = 113

processedFrames = []
# Load a bunch of results from first iteration
rawFrames = pickle.load(open('rawFrames.p','rb'))
colorMap = pickle.load(open('colormap.p','rb'))
clusterId = pickle.load(open('EnforcedClusterId.p', 'rb'))
tau = 0.02		# same as in readVideo.py

# get N, M
img = rawFrames[0]
[N, M, d] = img.shape  # dimensions

# initialize clusterNodes : cid -> list of pixels
clusterNodes = {}
# build clusterNodes 
for node, clusterIndex in clusterId.iteritems():
	if clusterIndex not in clusterNodes:
		clusterNodes[clusterIndex] = []
	clusterNodes[clusterIndex].append(node)

# build descriptors for histogram : cid -> histogram
descrpR = {}		

# HELPER FUNCTIONS : 
def findNeighbors():
	for node, clusterIndex in clusterId.iteritems():
		for neighborNode in thirteenNeighbors(node,N,M,len(rawFrames)):
			neighborClusterIndex = clusterId[neighborNode]
			if clusterIndex != neighborClusterIndex:
				clusterNeighborMap[clusterIndex].add(neighborClusterIndex)
				clusterNeighborMap[neighborClusterIndex].add(clusterIndex)

def chiSquaredDistance(hist1, hist2):
	dist = sum(map(lambda x,y: 0 if (x + y == 0) else (x-y)**2 / (x+y), hist1, hist2))		
	return dist*255*math.sqrt(3)/2
#	dist = cv2.compareHist(hist1, hist2, cv2.cv.CV_COMP_CHISQR)
# implement flow here

# SEGMENTATION ALGORITHM : 
# Iterative

edges = []
for h in range(hierarchy):
	print h
	tau *= 1.1
	print tau

	# INITIALIZE STUFF
	IntR = {cid : 0 for cid in clusterNodes}	# cid -> variation of a region
	# build adjacency map for clusters: cid -> set of neighbors
	clusterNeighborMap = {cid: set() for cid in clusterNodes}
	clusterSize = Counter([cid for cid in clusterNodes])
	
	# Build histogram and store descriptors for each cluster
	print "build histograms"
	for cid in clusterNodes:
		# compute RGB histogram
		# generate a list of RGB values
		values = []
		for ((x,y),f) in clusterNodes[cid]:
			values.append(rawFrames[f][x,y])

		# flatten histogram
		hist = cv2.calcHist([np.array([values], dtype=np.uint8)],[0,1,2],None,[20,20,20],[0,256, 0 ,256, 0 ,256])
		hist1D = []
		for a in hist:
			for b in a:
				for c in b:
					hist1D.append(float(c)/len(values))
		descrpR[cid] = np.array(hist1D) # a python list of images
	
	# build adjacency map
	findNeighbors()

	# calculate edge weights
	print "calculate edges for ", len(clusterNodes)," clusters"
	for cid in clusterNodes:	
		neighborsCid = clusterNeighborMap[cid]
		for ncid in neighborsCid:
				edges.append([chiSquaredDistance(descrpR[cid], descrpR[ncid]), cid, ncid])

	# sort edge weights
	print "sort edges", len(edges)
	edges.sort()

	print max(edges)
	print min(edges)
	
	merge_cnt = 0

	# merge clusters 
	print "start merging"

	for i in range(len(edges)):
		
		(weight, cid1, cid2) = edges[i]
		if cid1 == cid2:
			continue

		# if edge weight < both regions then merge
		if weight <= (IntR[cid1] + tau / clusterSize[cid1]) and weight <= (IntR[cid2] + tau / clusterSize[cid2]):
			
			merge_cnt += 1
		
			# new R of compound region
			IntR[cid1] = max(IntR[cid1],IntR[cid2],weight)
			del IntR[cid2]

			# update cluster informations
			clusterSize[cid1] += clusterSize[cid2]
			del clusterSize[cid2]
		
			for pos, cid in clusterId.iteritems():
				if cid == cid2:
					clusterId[pos] = cid1		

			clusterNodes[cid1].extend(clusterNodes[cid2]) 
			del clusterNodes[cid2]

			for j in range(i + 1, len(edges)):
				if edges[j][1] == cid2:
					edges[j][1] = cid1
				if edges[j][2] == cid2:
					edges[j][2] = cid1

			clusterNeighborMap[cid1] = clusterNeighborMap[cid1].union(clusterNeighborMap[cid2])
			del clusterNeighborMap[cid2]

	print "storing processed images"
	for f in range(len(rawFrames)):
		tmp = [[colorMap[clusterId[((x, y),f)]] for y in range(M)] for x in range(N)]
		processedFrames.append(np.array(tmp, dtype=np.uint8))

	# Final: display processed results
	for f in range(len(rawFrames)):
		imageio.imwrite('results/h='+str(1+h)+'_'+str(f)+'.png',processedFrames[f])
		if (0xFF & cv2.waitKey(5) == 27) or processedFrames[f].size == 0:
			break
	
	print "merged ",merge_cnt," clusters"

	edges = []
	descrpR = {}
	IntR = {}
	clusterNeighborMap = {}
	clusterSize = {}
	processedFrames = []

# Dump intermediate results
pickle.dump(clusterId, open('IterClusterId_30.p', 'wb'))
