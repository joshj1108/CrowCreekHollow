# CCH-CONSOLIDATED-003 Final Polish: two small pieces of farmhouse art.
# Run from the project folder: python tools/cchfp_interior.py
#   art/farm/fc/shelf_books.png  a short wall shelf (21x15) over the desk: a plank on two brackets carrying four upright books in fc/books.png's colours and a ledger
#                                lying flat, so the desk corner reads as the place for accounts and the catalogue.
#   art/farm/fi/rug_bed.png      the braided rug's blue and green rings warmed to muted ochre, olive and slate-brown,
#                                so it belongs with the hall's red rug and the wood (the untouched rug is kept in
#                                art/style_tests/CCH-003-FP/before/rug_bed.png and read from there).
import colorsys
import os
import shutil
from PIL import Image
import numpy as np

BEFORE = "art/style_tests/CCH-003-FP/before"


def shelf():
    books = np.array(Image.open("art/farm/fc/books.png").convert("RGBA"))
    W, H = 21, 15
    out = np.zeros((H, W, 4), np.uint8)
    ol = np.array([28, 20, 16, 255], np.uint8)
    lit, wood, shade = [122, 86, 56, 255], [92, 62, 40, 255], [62, 42, 28, 255]
    # The plank (rows 8-9 with an outline round it) and two brackets under it.
    shelf_y = 9
    out[shelf_y - 1, 0:W] = ol
    out[shelf_y, 0:W] = lit
    out[shelf_y + 1, 0:W] = wood
    out[shelf_y + 2, 0:W] = ol
    out[shelf_y - 1:shelf_y + 3, 0] = ol
    out[shelf_y - 1:shelf_y + 3, W - 1] = ol
    for bx in (3, W - 5):
        out[shelf_y + 3, bx:bx + 2] = shade
        out[shelf_y + 4, bx + 1] = shade
        out[shelf_y + 3:shelf_y + 5, bx + 2] = ol
        out[shelf_y + 5, bx + 1] = ol
    # Book colours from fc/books: one middle tone from each band.
    cols = []
    for y in range(books.shape[0]):
        px = books[y][books[y, :, 3] > 0]
        if len(px) and px[len(px) // 2][:3].sum() > 120:
            cols.append(px[len(px) // 2])
    picks = [cols[len(cols) * i // 4] for i in range(4)] if len(cols) >= 4 else [np.array([120, 40, 40, 255])] * 4
    x = 2
    for i, (w, h) in enumerate([(2, 7), (2, 6), (3, 7), (2, 5)]):
        c = picks[i]
        top = shelf_y - 1 - h
        out[top:shelf_y - 1, x:x + w] = c
        out[top:shelf_y - 1, x] = np.clip(c.astype(int) + [24, 20, 14, 0], 0, 255)      # lit spine edge
        out[top + 2, x:x + w] = np.clip(c.astype(int) + [40, 34, 20, 0], 0, 255)   # a band on the spine
        out[top - 1, x - 1:x + w + 1] = ol
        out[top:shelf_y - 1, x - 1] = ol
        out[top:shelf_y - 1, x + w] = ol
        x += w + 1
    # The ledger lying flat at the right end: a dark green cover, pale page edges.
    lx = x
    out[shelf_y - 4, lx - 1:lx + 6] = ol
    out[shelf_y - 3, lx:lx + 5] = [74, 90, 60, 255]
    out[shelf_y - 2, lx:lx + 5] = [214, 200, 168, 255]
    out[shelf_y - 4:shelf_y - 1, lx - 1] = ol
    out[shelf_y - 4:shelf_y - 1, lx + 5] = ol
    Image.fromarray(out).save("art/farm/fc/shelf_books.png")


def rug():
    os.makedirs(BEFORE, exist_ok=True)
    b = os.path.join(BEFORE, "rug_bed.png")
    if not os.path.exists(b):
        shutil.copy("art/farm/fi/rug_bed.png", b)
    a = np.array(Image.open(b).convert("RGBA"))
    for y in range(a.shape[0]):
        for x in range(a.shape[1]):
            r, g, bl, al = [int(v) for v in a[y, x]]
            if al == 0:
                continue
            h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, bl / 255)
            if s < 0.12:
                continue
            if 0.5 <= h <= 0.75:            # blue rings -> slate-brown
                h, s = 0.07, s * 0.45
            elif 0.2 <= h < 0.5:            # green rings -> olive-ochre
                h, s = 0.12, s * 0.9
            else:
                continue
            nr, ng, nb = colorsys.hsv_to_rgb(h, s, v)
            a[y, x, :3] = [round(nr * 255), round(ng * 255), round(nb * 255)]
    Image.fromarray(a).save("art/farm/fi/rug_bed.png")


if __name__ == "__main__":
    shelf()
    rug()
    print("done")
