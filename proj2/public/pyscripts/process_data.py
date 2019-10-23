import json
import sys

firstTimeStamp = 1
lastTimeStamp = 29649
tbins = 10
interval = (lastTimeStamp - firstTimeStamp) / tbins
cbins = 20


def open_file(path):
  with open(path, encoding='utf-8') as dfile:
    data = json.loads(dfile.read())
  return data

def process(data):
  TIME = 0
  COUNT = 1
  N = len(data)
  # Create bin buckets
  samples = [[0 for j in range(tbins)] for i in range(N)]
  counts  = [[0 for j in range(tbins)] for i in range(N)]
  curr = [0 for i in range(N)]
  # For each timestamp
  for record in range(N):
    track = data[record]
    last = 1
    curr[record] = data[record][0][COUNT]
    for point in track:
      if point[TIME] == 1:
        continue
      for i in range(last, point[TIME]):
        time_bin = int((i - firstTimeStamp) / interval)
        samples[record][time_bin] += curr[record]
        counts[record][time_bin] += 1
      curr[record] = point[COUNT]
      last = point[TIME]
  for i in range(N):
    for j in range(tbins):
      samples[i][j] = int(samples[i][j] / counts[i][j])
  return samples

print(sys.argv[1])
filename = sys.argv[1]
monomers = open_file(filename)
nodes = [{"name":"t"+str(t)+"c"+str(c)} for c in range(cbins) for t in range(tbins)]

samples = process(monomers['data'])
c_max = max([max(x) for x in samples])
print("Max: ", c_max)
c_interval = c_max / cbins

mgraph = {}

def c(sample):
  cbin = int(sample / c_interval)
  if cbin >= cbins:
    cbin = cbins - 1
  return cbin

for sample in samples:
  for i in range(0, len(sample)-1):
    link = "t"+str(i)+"c"+str(c(sample[i]))+':'+"t"+str(i+1)+"c"+str(c(sample[i+1]))
    if link in mgraph:
      mgraph[link] += sample[i] 
    else:
      mgraph[link] = sample[i]

links = []
for k,v in mgraph.items():
  source, target = k.split(":")
  links.append({"source":source, "target":target, "value":str(v)})

# clean nodes 
removeNodes = []
for node in nodes:
  present = False
  for link in links:
    if node["name"] == link["source"] or node["name"] == link["target"]:
      present = True
      break
  if not present:
    removeNodes.append(node)

for node in removeNodes:
  if node in nodes:
    nodes.remove(node)

data = {"links": links, "nodes": nodes}
with open(filename.replace('.json', '-graph.json'), 'w') as outfile:
  json.dump(data, outfile)


