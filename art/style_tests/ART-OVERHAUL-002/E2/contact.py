import sys,os
from PIL import Image,ImageDraw
out=sys.argv[1]; n=int(sys.argv[2]); keys=sys.argv[3:]
rows=[]
for k in keys:
    ims=[Image.open('raw/%s/%02d.png'%(k,i)).convert('RGBA') for i in range(n) if os.path.exists('raw/%s/%02d.png'%(k,i))]
    rows.append((k,ims))
w=max(im.width for k,ims in rows for im in ims); h=max(im.height for k,ims in rows for im in ims); s=2
cols=n
sheet=Image.new('RGBA',(cols*(w*s+2)+40,sum((max(i.height for i in ims)*s+12) for k,ims in rows)),(92,100,80,255))
d=ImageDraw.Draw(sheet); y=0
for k,ims in rows:
    rh=max(i.height for i in ims)*s
    d.text((0,y+2),k[:6],fill=(255,255,0,255))
    for i,im in enumerate(ims):
        x=40+i*(w*s+2); b=im.resize((im.width*s,im.height*s),Image.NEAREST); sheet.paste(b,(x,y+10),b); d.text((x,y),str(i),fill=(255,255,255,255))
    y+=rh+12
sheet.save(out); print(sheet.size)
