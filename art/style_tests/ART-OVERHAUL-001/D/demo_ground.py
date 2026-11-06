import json, sys, random
from PIL import Image
BIT = {'NW': 1, 'NE': 2, 'SW': 4, 'SE': 8}
def pack(key):
    m = json.load(open('raw/%s/meta.json' % key)); sh = Image.open('raw/%s/sheet.png' % key).convert('RGBA')
    out = Image.new('RGBA', (64, 64))
    for t in m['tileset_data']['tiles']:
        mask = sum(BIT[c] for c, v in t['corners'].items() if v == 'upper')
        b = t['bounding_box']; out.paste(sh.crop((b['x'], b['y'], b['x'] + 16, b['y'] + 16)), ((mask % 4) * 16, (mask // 4) * 16))
    return out
if __name__ == '__main__':
    random.seed(3); W, H = 24, 14
    grid = [[0] * W for _ in range(H)]
    x = 2
    for y in range(H):
        x = max(1, min(W - 4, x + random.choice([-1, 0, 1, 1])))
        for dx in range(2): grid[y][x + dx] = 1
    for y in range(4, 7):
        for xx in range(12, 19): grid[y][xx] = 1
    row = []
    for key in sys.argv[1:]:
        p = pack(key); img = Image.new('RGBA', (W * 16, H * 16))
        for y in range(H + 1):
            for x in range(W + 1):
                g = lambda a, b: grid[b][a] if 0 <= a < W and 0 <= b < H else 0
                mask = g(x - 1, y - 1) | g(x, y - 1) << 1 | g(x - 1, y) << 2 | g(x, y) << 3
                img.paste(p.crop(((mask % 4) * 16, (mask // 4) * 16, (mask % 4) * 16 + 16, (mask // 4) * 16 + 16)), (x * 16 - 8, y * 16 - 8))
        row.append(img)
    out = Image.new('RGBA', (W * 16 * 2 + 8, (H * 16 + 8) * ((len(row) + 1) // 2)), (0, 0, 0, 255))
    for i, im in enumerate(row): out.paste(im, ((i % 2) * (W * 16 + 8), (i // 2) * (H * 16 + 8)))
    out = out.resize((out.width * 2, out.height * 2), Image.NEAREST); out.save('raw/ground_demo.png'); print(out.size)
