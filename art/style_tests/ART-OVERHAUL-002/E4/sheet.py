import sys,os
from PIL import Image, ImageDraw
key=sys.argv[1]; idx=[int(x) for x in sys.argv[2].split(',')]; s=int(sys.argv[3]) if len(sys.argv)>3 else 3
ims=[Image.open('raw/%s/%02d.png'%(key,i)).convert('RGBA') for i in idx]
w,h=ims[0].size; cw=w*s+8; ch=h*s+14
cols=min(len(ims),12); rows=(len(ims)+cols-1)//cols
sh=Image.new('RGBA',(cols*cw,rows*ch),(110,120,105,255)); d=ImageDraw.Draw(sh)
for k,(i,im) in enumerate(zip(idx,ims)):
    x=(k%cols)*cw; y=(k//cols)*ch
    sh.alpha_composite(im.resize((w*s,h*s),Image.NEAREST),(x+4,y+12)); d.text((x+2,y),str(i),fill='yellow')
sh.save('pick_%s.png'%key)
