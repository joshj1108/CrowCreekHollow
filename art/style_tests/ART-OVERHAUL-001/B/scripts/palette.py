"""B-1: extract the FARM-001R palette (hillside, boulders, fir, ground chunks, fringe, ferns) and build the
reference strip used as a labelled PixelLab reference. Writes palette.json, palette.png and refs.png next to B/."""
import json, glob, os
from PIL import Image
B = os.path.join(os.path.dirname(__file__), '..')
C = 'art/farm/concept/'
srcs = ['art/farm/hillside.png', C + 'hill_foot.png', C + 'src_fir.png', C + 'fern_a.png', C + 'fern_b.png'] \
    + sorted(glob.glob(C + 'r3_boulders_*.png')) + [C + 'ground_day_1_1.png', C + 'ground_day_1_2.png', C + 'ground_day_0_1.png']
groups = {  # quantized per material, so the stone greys aren't averaged into the greens
    'stone': (['art/farm/hillside.png'] + sorted(glob.glob(C + 'r3_boulders_*.png')), 16),
    'plants': ([C + 'src_fir.png', C + 'fern_a.png', C + 'fern_b.png', C + 'hill_foot.png'], 12),
    'ground': ([C + 'ground_day_1_1.png', C + 'ground_day_1_2.png', C + 'ground_day_0_1.png'], 8)}
cols = set()
for name, (files, n) in groups.items():
    px = []
    for f in files:
        px += [p[:3] for p in Image.open(f).convert('RGBA').get_flattened_data() if p[3] == 255]
    strip = Image.new('RGB', (len(px), 1)); strip.putdata(px)
    q = strip.quantize(colors=n, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    pal = q.getpalette()[:n * 3]
    cols |= {tuple(pal[i:i + 3]) for i in range(0, len(pal), 3)}
cols = sorted(cols, key=lambda c: sum(c))
# the cave's dark steps, from the darkest farm outline down to near-black (not pure black)
for c in [(14, 12, 16), (22, 19, 22), (31, 27, 29)]:
    if c not in cols: cols.insert(0, c)
hexes = ['#%02x%02x%02x' % c for c in cols]
json.dump({'sources': srcs, 'colors': hexes}, open(os.path.join(B, 'palette.json'), 'w'), indent=1)
sw = Image.new('RGB', (len(cols) * 8, 8))
for i, c in enumerate(cols):
    sw.paste(c, (i * 8, 0, i * 8 + 8, 8))
sw.save(os.path.join(B, 'palette.png'))
# reference strip: hillside + boulders at 1x on a dark-green ground, so the model sees real tile density
refs = [Image.open('art/farm/hillside.png').convert('RGBA')] + [Image.open(f).convert('RGBA') for f in sorted(glob.glob(C + 'r3_boulders_*.png'))][:4] \
    + [Image.open(C + 'fern_a.png').convert('RGBA'), Image.open(C + 'src_fir.png').convert('RGBA')]
w = sum(r.width for r in refs) + 4 * (len(refs) + 1); h = max(r.height for r in refs) + 8
board = Image.new('RGBA', (w, h), (58, 66, 48, 255)); x = 4
for r in refs:
    board.alpha_composite(r, (x, h - 4 - r.height)); x += r.width + 4
board.save(os.path.join(B, 'refs.png'))
print(len(hexes), hexes); print('refs', board.size)
