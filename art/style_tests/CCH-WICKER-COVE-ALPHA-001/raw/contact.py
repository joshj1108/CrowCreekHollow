import sys, glob
from PIL import Image, ImageDraw
def sheet(keys, out, scale=2, bg=(70,78,84)):
    rows=[]
    for k in keys:
        ims=[Image.open(f).convert('RGBA') for f in sorted(glob.glob(k+'/*.png'))]
        rows.append((k,ims))
    W=max(sum(i.width*scale+6 for i in ims) for k,ims in rows)+60
    H=sum(max(i.height for i in ims)*scale+14 for k,ims in rows)
    S=Image.new('RGBA',(W,H),bg+(255,)); d=ImageDraw.Draw(S); y=0
    for k,ims in rows:
        d.text((2,y+2),k,fill=(255,255,255)); x=60
        for n,i in enumerate(ims):
            S.alpha_composite(i.resize((i.width*scale,i.height*scale),Image.NEAREST),(x,y+12)); d.text((x,y),str(n),fill=(255,255,0)); x+=i.width*scale+6
        y+=max(i.height for i in ims)*scale+14
    S.save(out)
if __name__=='__main__':
    sheet(sys.argv[2].split(','), sys.argv[1], int(sys.argv[3]) if len(sys.argv)>3 else 2)
