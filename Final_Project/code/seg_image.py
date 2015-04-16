import imageio
import math
import operator
from collections import Counter
import random
import numpy
img = imageio.imread('twitter.png')
[N, M, d] = img.shape  # dimensions

# BUILD LOOKUPs
# initialize clusterId : node (coordinate) -> cluster
clusterId = {}
cid = 0
for x in range(N):
	for y in range(M):
		clusterId[(x,y)] = cid
		cid += 1

# initialize clusterSize : cluster -> number of nodes
clusterSize = Counter([cid for cid in clusterId.itervalues()])

# initialize IntR : cluster -> R value (largest edge weight)
IntR = {n : 0 for n in range(len(clusterId))}

# HELPER FUNCTIONS
def eightNeighbors((x,y)):
	ret = [(x-1,y-1),(x-1, y),(x-1, y+1),(x,y-1),(x,y+1),(x+1,y-1),(x+1,y),(x+1,y+1)]
	ret = [(s,t) for (s,t) in ret if s >= 0 and s < N and t >= 0 and t < M]
	return ret
#print eightNeighbors(1,1,N,M)

def pixelDistance((x1,y1),(x2,y2)):
	return math.sqrt((int(img[x1,y1,0])-int(img[x2,y2,0]))**2 + (int(img[x1,y1,1])-int(img[x2,y2,1]))**2 + (int(img[x1,y1,2])-int(img[x2,y2,2]))**2)/255.0

# SEGMENTATION ALGORITHM : oversegmentation and merging
tau = 0.02
# 1. sort graph by weight	
edges = []						# ((x1,y1),(x2,y2))-> weight w
for node in clusterId:
	neighbors = eightNeighbors(node)
	for n in neighbors:
		edges.append((pixelDistance(node,n), node, n))
sorted_edges = sorted(edges)

# 2. for each region, calculate R with eq (1), tau *= 1.1
for weight, n1, n2 in sorted_edges:
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

# 3. output first iteration
colorMap = {}		# clusterId -> RGB	
for v in clusterId.values():
	if v not in colorMap:
		colorMap[v] = [random.randint(0,255),random.randint(0,255),random.randint(0,255)]

output = [[colorMap[clusterId[(x, y)]] for y in range(M)] for x in range(N)]
imageio.imwrite('firstIter.png', numpy.array(output, dtype=numpy.uint8))

# speedup : map{clusterid ->}