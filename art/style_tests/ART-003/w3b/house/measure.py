# Landmarks of a 192x160 house sprite: lit window glass centres, the door's columns, the wall/footing bottom row,
# the steps, the opaque bounds. python measure.py file.png [...]
import sys
from PIL import Image
for f in sys.argv[1:]:
    im = Image.open(f).convert('RGBA'); px = im.load(); W, H = im.size
    glow = [(x, y) for y in range(85, 140) for x in range(W) if px[x, y][3] > 128 and px[x, y][0] > 200 and px[x, y][1] > 150 and px[x, y][2] < 150]
    out = []
    for lo, hi in ((0, 80), (112, 192)):
        g = [(x, y) for x, y in glow if lo <= x < hi]
        if g:
            xs = [p[0] for p in g]; ys = [p[1] for p in g]
            out.append('window x %d..%d c=%.1f  y %d..%d c=%.1f' % (min(xs), max(xs), (min(xs) + max(xs)) / 2, min(ys), max(ys), (min(ys) + max(ys)) / 2))
    # wall bottom: last row where opaque pixels span more than 60% of the width
    rows = [y for y in range(H) if sum(px[x, y][3] > 128 for x in range(W)) > 0.6 * W]
    span = lambda y: [x for x in range(W) if px[x, y][3] > 128]
    wb = max(rows)
    st = [y for y in range(wb + 1, H) if span(y)]
    stx = span(wb + 2) if wb + 2 < H else []
    print(f, im.size, 'bbox', im.getbbox(), '| walls x %d..%d bottom y %d' % (min(span(wb - 3)), max(span(wb - 3)), wb),
          '| steps y %s x %s' % ((st[0], st[-1]) if st else '-', (min(stx), max(stx), (min(stx) + max(stx)) / 2) if stx else '-'))
    for o in out:
        print('   ', o)
