# returns a bunch of pixel coordinates
def thirteenNeighbors(((x,y),frameIndex),N,M,d):
	# 8 neighbors in same frame
	tmp = [(x,y+1),(x+1,y-1),(x+1,y),(x+1,y+1)]
	ret = [((s,t),frameIndex) for (s,t) in tmp if s >= 0 and s < N and t >= 0 and t < M]

	# 9 neighbors in next frame
	frameIndex += 1
	if frameIndex < d:
		tmp = [(x-1,y-1),(x-1, y),(x,y),(x-1, y+1),(x,y-1),(x,y+1),(x+1,y-1),(x+1,y),(x+1,y+1)]
		ret += [((s,t),frameIndex) for (s,t) in tmp if s >= 0 and s < N and t >= 0 and t < M]
	return ret

	
