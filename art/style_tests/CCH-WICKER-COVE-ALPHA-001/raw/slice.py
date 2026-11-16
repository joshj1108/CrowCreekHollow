from PIL import Image, ImageDraw
import sys
def comps(im, minpx=40):
    a=im.split()[3].load(); W,H=im.size; seen=set(); out=[]
    for y in range(H):
        for x in range(W):
            if a[x,y]>0 and (x,y) not in seen:
                st=[(x,y)]; seen.add((x,y)); pts=[]
                while st:
                    p=st.pop(); pts.append(p)
                    for dx,dy in ((1,0),(-1,0),(0,1),(0,-1),(1,1),(-1,-1),(1,-1),(-1,1)):
                        q=(p[0]+dx,p[1]+dy)
                        if 0<=q[0]<W and 0<=q[1]<H and q not in seen and a[q]>0: seen.add(q); st.append(q)
                xs=[p[0] for p in pts]; ys=[p[1] for p in pts]
                out.append([min(xs),min(ys),max(xs)+1,max(ys)+1,len(pts)])
    return [c for c in out if c[4]>=minpx]
if __name__=='__main__':
    S=Image.new('RGBA',(4*300,320),(70,78,84,255)); d=ImageDraw.Draw(S)
    for n in range(4):
        im=Image.open('props/%02d.png'%n).convert('RGBA'); cs=comps(im)
        S.alpha_composite(im.resize((256,256),Image.NEAREST),(n*300,40))
        for i,c in enumerate(cs):
            d.rectangle([n*300+c[0]*2,40+c[1]*2,n*300+c[2]*2,40+c[3]*2],outline=(255,0,0)); d.text((n*300+c[0]*2,40+c[1]*2),str(i),fill=(255,255,0))
            print(n,i,c)
    S.save('sheet_props_sliced.png')
