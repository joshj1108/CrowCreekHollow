"""PixelLab 32 px pro candidates came back shifted by half a cell: join them in order and cut by transparent columns."""
import sys, os, numpy as np
from PIL import Image
k=sys.argv[1]; n=int(sys.argv[2])
ims=[np.array(Image.open('raw/%s/%02d.png'%(k,i)).convert('RGBA')) for i in range(n)]
strip=np.concatenate(ims,axis=1); col=(strip[...,3]>0).any(0)
out='raw/%s_fix'%k; os.makedirs(out,exist_ok=True); runs=[]; x=0
while x<len(col):
    if col[x]:
        s=x
        while x<len(col) and col[x]: x+=1
        runs.append((s,x))
    x+=1
c=0
for s,e in runs:
    if 8<=e-s<=32:
        Image.fromarray(strip[:,s:e]).save(os.path.join(out,'%02d.png'%c)); c+=1
print(k,len(runs),c)
