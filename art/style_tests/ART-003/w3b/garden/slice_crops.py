# ART-003 W-3 Batch B (non-production): crops_gen.png (PixelLab pixflux 128x32, one strip of eight ripe crops on a
# shared soil line) -> crops_w3b.png, eight cells of 16x32, each plant on its own, the soil line removed (the bed's
# soil is under them in the game). Order: corn, pumpkin, beans, cabbage, kale, squash, turnip, sunflower.
from PIL import Image
im = Image.open('crops_gen.png').convert('RGBA')
W, H = im.size
px = im.load()
def soil(c):   # the shared ground line: low, brown, unsaturated-green pixels in the bottom rows
    r, g, b, a = c
    return a > 0 and r > g and r - b > 10 and g < 90
# The ground line's top: the first row from the bottom with most of its pixels soil.
line = H
for y in range(H - 1, H - 10, -1):
    if sum(soil(px[x, y]) for x in range(W)) > W * 0.45:
        line = y
print('soil line from row', line)
# Cut between plants at the emptiest column within 4 px of each 16 px boundary (leaves overlap a little).
occ = [sum(px[x, y][3] > 0 for y in range(0, line)) for x in range(W)]
cuts = [0] + [min(range(16 * k - 4, 16 * k + 5), key=lambda c: (occ[c], abs(c - 16 * k))) for k in range(1, 8)] + [W]
merged = [(cuts[i], cuts[i + 1] - 1) for i in range(8)]
print('cells', merged)
out = Image.new('RGBA', (16 * len(merged), 32), (0, 0, 0, 0))
for i, (a, b) in enumerate(merged):
    cell = Image.new('RGBA', (b - a + 1, line + 2), (0, 0, 0, 0))
    cp = cell.load()
    for y in range(line + 2):
        for x in range(a, b + 1):
            c = px[x, y]
            if y >= line and soil(c):
                continue
            cp[x - a, y] = c
    cell = cell.crop(cell.getbbox())
    if cell.width > 16:   # never resample: trim the outermost leaf columns evenly
        k = (cell.width - 16) // 2
        cell = cell.crop((k, 0, k + 16, cell.height))
    out.alpha_composite(cell, (i * 16 + (16 - cell.width) // 2, 32 - cell.height))
out.save('crops_w3b.png')
out.resize((out.width * 6, out.height * 6), Image.NEAREST).save('../_crops_w3b6x.png')
print('crops_w3b.png', out.size)
