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
hierarchy = 113				# pixel_range(0-1) * init_tau(0.02)*tau_rate(1.1)^n = max_chi_squared_dist(2) 
tau = 0.02					# must be same as in readVideo.py
tau_rate = 1.1 
processedFrames = []
# Load a bunch of results from first iteration
rawFrames = pickle.load(open('rawFrames.p','rb'))
colorMap = pickle.load(open('colormap.p','rb'))
clusterId = pickle.load(open('EnforcedClusterId.p', 'rb'))	# pixel ((coordinates), frame) -> cluster id
rawFlow = pickle.load(open('rawFlow.p', 'rb'))				# rawFlow[frameIdx] : (N, M, 2)

# get N, M
img = rawFrames[0]
[N, M, d] = img.shape  # dimensions

# INITIALIZE LOOKUP MAPS
# clusterNodes : cid -> list of pixels
clusterNodes = {}
# build clusterNodes 
for pixel, clusterIndex in clusterId.iteritems():
	if clusterIndex not in clusterNodes:
		clusterNodes[clusterIndex] = []
	clusterNodes[clusterIndex].append(pixel)

# build descriptors for histogram : cid -> histogram
colorDescrpR = {}		
flowDescrpR = {}

print "build clusterFlow"
# build clusterFlow : cid -> flow of cluster (numFrames x 16)
clusterFlow = {}
for pixel, clusterIndex in clusterId.iteritems():
	if clusterIndex not in clusterFlow:
		clusterFlow[clusterIndex] = np.zeros((len(rawFrames), 16)) + 10**-16
	((x,y),f) = pixel
	if f == len(rawFrames) - 1:
		continue
	dx = rawFlow[f][x,y][0]
	dy = rawFlow[f][x, y][1]
	angle = round(math.degrees(math.atan2(dy,dx))* 16 / 360) 
	clusterFlow[clusterIndex][f][angle%16] += (math.sqrt(dx**2 + dy**2) )

edges = []
# HELPER FUNCTIONS :
def thirteenNeighborsAlongFlow(((x,y),frameIndex),N,M,d):
	# 8 neighbors in same frame
	tmp = [(x,y+1),(x+1,y-1),(x+1,y),(x+1,y+1)]
	ret = [((s,t),frameIndex) for (s,t) in tmp if s >= 0 and s < N and t >= 0 and t < M]

	# 9 neighbors along flow vector
	frameIndex -= 1
	if frameIndex >= 0:
		dx = round(rawFlow[frameIndex][x, y][0])
		dy = round(rawFlow[frameIndex][x, y][1]) 
		tmp = [(x-1,y-1),(x-1, y),(x,y),(x-1, y+1),(x,y-1),(x,y+1),(x+1,y-1),(x+1,y),(x+1,y+1)]
		tmp = map(lambda i,j : (i + dx, j + dy), tmp)
		ret += [((s,t),frameIndex) for (s,t) in tmp if s >= 0 and s < N and t >= 0 and t < M]
	return ret 

# computes clusterNeighborMap[clusterId] -> a list of 26 neighbors
def findNeighbors():
	for node, clusterIndex in clusterId.iteritems():
		for neighborNode in thirteenNeighbors(node,N,M,len(rawFrames)):
			neighborClusterIndex = clusterId[neighborNode]
			if clusterIndex != neighborClusterIndex:
				clusterNeighborMap[clusterIndex].add(neighborClusterIndex)
				clusterNeighborMap[neighborClusterIndex].add(clusterIndex)

# distance measure of two histograms
def chiSquaredDistance(chist1, chist2, fhist1, fhist2):
	dc = sum(map(lambda x,y: 0 if (x + y == 0) else (x-y)**2 / (x+y), chist1, chist2))/2		
	df = sum(map(lambda x,y: 0 if (x + y == 0) else (x-y)**2 / (x+y), fhist1, fhist2))/2
	dist = (1 - (1 - dc)*(1-df))**2
	return dist#*math.sqrt(3)

# SEGMENTATION ALGORITHM : (Iterative)
skipCalStat = False

for h in range(hierarchy):
	print h

	if skipCalStat is False:
		print "not skipping calculating stats"
		#INITIALIZE STUFF
		# internal variation for each cluster
		IntR = {cid : 0 for cid in clusterNodes}	# cid -> variation of a region
		
		# build adjacency map for clusters: cid -> set of neighbors
		clusterNeighborMap = {cid: set() for cid in clusterNodes}
		clusterSize = Counter([cid for cid in clusterNodes])

		# Build RGB histogram for each cluster
		#REPORT: use another color space? 
		print "build histograms"
		for cid in clusterNodes:
			# generate a list of RGB values
			colorvalues = []
			histvalues = []
			for ((x,y),f) in clusterNodes[cid]:
				colorvalues.append(rawFrames[f][x,y])

			# flatten histogram
			colorHist = cv2.calcHist([np.array([colorvalues], dtype=np.float32)],[0,1,2],None,[20,20,20],[0,1, 0 ,1, 0 ,1])
			colorHist1D = []

			for a in colorHist:
				for b in a:
					for c in b:
						colorHist1D.append(float(c)/len(colorvalues))
			colorDescrpR[cid] = np.array(colorHist1D) 		# a python list of images
			
			s = np.sum(clusterFlow[cid])

			flowDescrpR[cid] = clusterFlow[cid].flatten() / s 

		# build adjacency map
		findNeighbors()

		# calculate edge weights
		print "calculate edges for ", len(clusterNodes)," clusters"
		for cid in clusterNodes:	
			neighborsCid = clusterNeighborMap[cid]
			for ncid in neighborsCid:
				edges.append([chiSquaredDistance(colorDescrpR[cid], colorDescrpR[ncid], flowDescrpR[cid], flowDescrpR[ncid]), cid, ncid])

		# sort edge weights
		print "sort edges", len(edges)
		edges.sort()

		print max(edges)
		print min(edges)
	
	# Merge clusters 
	print "start merging"
	merge_cnt = 0
	tau *= tau_rate
	print "tau ", tau

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
		imageio.imwrite('lab_flow_golf_moving/h='+str(1+h)+'_'+str(f)+'.png',processedFrames[f])
		if (0xFF & cv2.waitKey(5) == 27) or processedFrames[f].size == 0:
			break
	
	print "merged ",merge_cnt," clusters"

	if merge_cnt == 0 :
		skipCalStat = True
	else:	# reset stats
		skipCalStat = False
		edges = []
		colorDescrpR = {}
		flowDescrpR = {}
		IntR = {}
		clusterNeighborMap = {}
		clusterSize = {}
		processedFrames = []
		rawFlow = []

# Dump intermediate results
#pickle.dump(clusterId, open('IterClusterId_30.p', 'wb'))
