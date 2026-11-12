import sys
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage
def main_comp(p):
    a=np.array(Image.open(p).convert('RGBA'))
    m=a[...,3]>=128
    lab,n=ndimage.label(m,structure=np.ones((3,3)))
    if n==0: return Image.fromarray(a)
    sizes=ndimage.sum(m,lab,range(1,n+1)); k=1+int(np.argmax(sizes))
    keep=lab==k
    # keep small pieces close to main (within 1px dilation)
    near=ndimage.binary_dilation(keep,iterations=1)
    for j in range(1,n+1):
        if j!=k and (near&(lab==j)).any(): keep|=lab==j
    a[~keep]=0
    return Image.fromarray(a)
key=sys.argv[1]; ids=[int(x) for x in sys.argv[2:]]
s=8; ims=[main_comp('%s/%02d.png'%(key,i)) for i in ids]
w=ims[0].width*s+10
o=Image.new('RGBA',(w*len(ims),ims[0].height*s+20),(34,32,30,255)); d=ImageDraw.Draw(o)
for n,(i,im) in enumerate(zip(ids,ims)):
    bb=im.getbbox(); o.alpha_composite(im.resize((im.width*s,im.height*s),0),(n*w,16)); d.text((n*w+2,2),'%d %s'%(i,(bb[2]-bb[0],bb[3]-bb[1]) if bb else ''),fill=(230,220,190,255))
o.save(key+'_pick.png')
