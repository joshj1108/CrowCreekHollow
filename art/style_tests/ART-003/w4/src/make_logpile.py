# ART-003 W-4: a low stacked log pile, hand-assembled pixel by pixel with only the colours of the PixelLab
# r3/log.png (no generation). End grain toward the viewer, three rounds below and two above, 19x16.
import sys
from PIL import Image
P = {  # every colour is sampled from art/style_tests/ART-003/r3/log.png
    'O': (36, 28, 34), 'o': (42, 31, 24), 'D': (59, 42, 30), 'B': (90, 61, 38), 'b': (122, 84, 52),
    'L': (154, 109, 66), 'Y': (246, 196, 90), 'y': (244, 184, 80), 'r': (240, 160, 48), 'R': (160, 122, 76),
    'm': (125, 138, 62), 'M': (67, 85, 44), 'C': (200, 184, 154), '.': None,
}
CAPS = [[".OOOOO.",   # end grain: tan with a pale catch-light, a darker heart ring and a bark rim
         "ObCRRbO",
         "OCRbRRO",
         "ORbLbRO",
         "ORRbRBO",
         "ObBRBbO",
         ".OOOOO."],
        [".OOOOO.",
         "ObRCRbO",
         "ORRRRRO",
         "ORbLbRO",
         "ORRbRBO",
         "ObBBBbO",
         ".OOOOO."],
        [".OOOOO.",
         "ObCRRbO",
         "ORRbRRO",
         "ORbLRRO",
         "OBRRRBO",
         "ObBRBbO",
         ".OOOOO."]]
W, H = 19, 16
g = [['.'] * W for _ in range(H)]
def put(x, y, c):
    if 0 <= x < W and 0 <= y < H and c != '.':
        g[y][x] = c
def band(x0, x1, y, rows):   # the bark of a log's top, receding behind its end
    for k, row in enumerate(rows):
        for x in range(x0, x1 + 1):
            c = row[(x * 7 + y) % len(row)] if k else row[0]
            put(x, y + k, c)
# The two lower side logs' tops, seen past the upper pair; then the upper pair's tops.
band(0, 4, 6, ["O", "LbbL", "BDBB"])
band(14, 18, 6, ["O", "bLbb", "BBDB"])
band(4, 14, 0, ["O", "LbLbmbL", "BbDBMBB"])
for n, (x, y) in enumerate([(3, 3), (9, 3)]):
    for j, row in enumerate(CAPS[(n + 1) % 3]):
        for i, c in enumerate(row):
            put(x + i, y + j, c)
for n, (x, y) in enumerate([(0, 9), (6, 9), (12, 9)]):
    for j, row in enumerate(CAPS[n]):
        for i, c in enumerate(row):
            put(x + i, y + j, c)
# Close the outline where the bands meet the caps' shoulders.
for x, y in [(3, 2), (15, 2), (0, 8), (18, 8), (2, 6), (16, 6)]:
    put(x, y, 'O')
img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
for y in range(H):
    for x in range(W):
        if g[y][x] != '.':
            img.putpixel((x, y), P[g[y][x]] + (255,))
img.save(sys.argv[1])
