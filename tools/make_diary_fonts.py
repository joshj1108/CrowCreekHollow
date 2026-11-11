"""Draws the diary's two handwriting fonts as pixel fonts (DIARY-HAND-001): Agnes Rook's hand and your own.

    python tools/make_diary_fonts.py            # writes art/ui/diary/hand_agnes.(png|fnt) and hand_yours.(png|fnt)
    python tools/make_diary_fonts.py preview    # also a 4x preview of both hands in art/style_tests/DIARY-HAND-001/review/

Each glyph is drawn here by hand on a grid of 1 native px (the diary art's own pixel), 11 rows tall: rows 0-2 hold
ascenders, rows 3-7 the x-height (5 px), the baseline is under row 7, and rows 8-10 hold descenders. The fonts are
saved at 1x as BMFont text files (size 8), which Godot imports as FontFile; the diary asks for them at 16 (2x, the
UI's detail density, like the HUD icons and the diary's art) and titles at 24 (3x), scaled by whole steps with
nearest filtering, so they stay pixel-clean.

Agnes writes an older, careful journal hand: rounded letters, a slight forward slant (sheared in below, one step
over the x-height), tall ascenders, long descenders with a cursive f, and small exit flicks on the baseline strokes
(a, d, h, i, l, m, n, t, u) that reach across to the next letter, so it reads as print with a cursive habit. Your hand is a working print: upright,
squared bowls left open where the pen starts (c, e, o, s), narrow 3 px letters where they read, ascenders no taller than capitals and short descenders, no
flicks. Both keep a 5 px x-height, the same line and the same punctuation, so they sit in one book.
"""
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "art", "ui", "diary")
ROWS = 11          # glyph cell height
BASE = 8           # baseline: rows 0-7 sit on it
LINE = 12          # line height (one row of air between lines; the label adds its own spacing)

# Shared: digits and punctuation (top row, rows). Digits are capital height (rows 1-7).
COMMON = {
    "0": (1, [".##.", "#..#", "#..#", "#..#", "#..#", "#..#", ".##."]),
    "1": (1, [".#.", "##.", ".#.", ".#.", ".#.", ".#.", "###"]),
    "2": (1, [".##.", "#..#", "...#", "..#.", ".#..", "#...", "####"]),
    "3": (1, ["###.", "...#", "...#", ".##.", "...#", "...#", "###."]),
    "4": (1, ["#..#", "#..#", "#..#", "####", "...#", "...#", "...#"]),
    "5": (1, ["####", "#...", "###.", "...#", "...#", "#..#", ".##."]),
    "6": (1, [".##.", "#...", "#...", "###.", "#..#", "#..#", ".##."]),
    "7": (1, ["####", "...#", "..#.", "..#.", ".#..", ".#..", ".#.."]),
    "8": (1, [".##.", "#..#", "#..#", ".##.", "#..#", "#..#", ".##."]),
    "9": (1, [".##.", "#..#", "#..#", ".###", "...#", "...#", ".##."]),
    ".": (7, ["#"]),
    ",": (7, [".#", "#."]),
    "!": (1, ["#", "#", "#", "#", "#", ".", "#"]),
    "?": (1, [".##.", "#..#", "...#", "..#.", ".#..", "....", ".#.."]),
    "'": (1, ["#", "#"]),
    '"': (1, ["#.#", "#.#"]),
    ":": (4, ["#", ".", ".", "#"]),
    ";": (4, [".#", "..", "..", ".#", "#."]),
    "-": (5, ["###"]),
    "_": (8, ["####"]),
    "(": (1, [".#", "#.", "#.", "#.", "#.", "#.", "#.", ".#"]),
    ")": (1, ["#.", ".#", ".#", ".#", ".#", ".#", ".#", "#."]),
    "[": (1, ["##", "#.", "#.", "#.", "#.", "#.", "#.", "##"]),
    "]": (1, ["##", ".#", ".#", ".#", ".#", ".#", ".#", "##"]),
    "/": (1, ["..#", "..#", ".#.", ".#.", ".#.", "#..", "#.."]),
    "\\": (1, ["#..", "#..", ".#.", ".#.", ".#.", "..#", "..#"]),
    "+": (3, [".#.", ".#.", "###", ".#.", ".#."]),
    "=": (4, ["###", "...", "###"]),
    "*": (1, ["#.#", ".#.", "#.#"]),
    "<": (3, ["..#", ".#.", "#..", ".#.", "..#"]),
    ">": (3, ["#..", ".#.", "..#", ".#.", "#.."]),
    "%": (2, ["##..#", "##.#.", "..#..", ".#.##", "#..##"]),
    "&": (1, [".##..", "#..#.", "#.#..", ".#...", "#.#.#", "#..#.", ".##.#"]),
    "#": (2, [".#.#.", "#####", ".#.#.", "#####", ".#.#."]),
    "$": (1, [".###.", "#.#..", ".###.", "..#.#", ".###.", "..#.."]),
    "@": (2, [".###.", "#.###", "#.#.#", "#.###", "#....", ".###."]),
    "{": (1, ["..#", ".#.", ".#.", "#..", ".#.", ".#.", "..#"]),
    "}": (1, ["#..", ".#.", ".#.", "..#", ".#.", ".#.", "#.."]),
    "|": (1, ["#", "#", "#", "#", "#", "#", "#", "#"]),
    "~": (4, [".#.#", "#.#."]),
    "`": (1, ["#.", ".#"]),
    "^": (1, [".#.", "#.#"]),
}

# Agnes Rook: drawn upright here, then sheared (see _slant) so the hand leans forward.
AGNES = {
    "a": (3, [".###.", "#..#.", "#..#.", "#..#.", ".##.#"]),
    "b": (0, ["#...", "#...", "#...", "###.", "#..#", "#..#", "#..#", "###."]),
    "c": (3, [".###", "#...", "#...", "#...", ".###"]),
    "d": (0, ["...#.", "...#.", "...#.", ".###.", "#..#.", "#..#.", "#..#.", ".##.#"]),
    "e": (3, [".##.", "#..#", "####", "#...", ".###"]),
    "f": (0, ["..##", ".#..", ".#..", "###.", ".#..", ".#..", ".#..", ".#..", ".#..", ".#..", "#..."]),
    "g": (3, [".###", "#..#", "#..#", "#..#", ".###", "...#", "#..#", ".##."]),
    "h": (0, ["#....", "#....", "#....", "###..", "#..#.", "#..#.", "#..#.", "#..##"]),
    "i": (1, ["#.", "..", "#.", "#.", "#.", "#.", "##"]),
    "j": (1, ["..#", "...", "..#", "..#", "..#", "..#", "..#", "..#", "#.#", ".#."]),
    "k": (0, ["#...", "#...", "#...", "#..#", "#.#.", "##..", "#.#.", "#..#"]),
    "l": (0, ["#.", "#.", "#.", "#.", "#.", "#.", "#.", "##"]),
    "m": (3, ["####..", "#.#.#.", "#.#.#.", "#.#.#.", "#.#.##"]),
    "n": (3, ["###..", "#..#.", "#..#.", "#..#.", "#..##"]),
    "o": (3, [".##.", "#..#", "#..#", "#..#", ".##."]),
    "p": (3, ["###.", "#..#", "#..#", "#..#", "###.", "#...", "#...", "#..."]),
    "q": (3, [".###.", "#..#.", "#..#.", "#..#.", ".###.", "...#.", "...#.", "...##"]),
    "r": (3, ["#.##", "##..", "#...", "#...", "#..."]),
    "s": (3, [".###", "#...", ".##.", "...#", "###."]),
    "t": (1, [".#..", ".#..", "###.", ".#..", ".#..", ".#..", "..##"]),
    "u": (3, ["#..#.", "#..#.", "#..#.", "#..#.", ".##.#"]),
    "v": (3, ["#...#", "#...#", ".#.#.", ".#.#.", "..#.."]),
    "w": (3, ["#...#", "#...#", "#.#.#", "#.#.#", ".#.#."]),
    "x": (3, ["#...#", ".#.#.", "..#..", ".#.#.", "#...#"]),
    "y": (3, ["#..#", "#..#", "#..#", "#..#", ".###", "...#", "#..#", ".##."]),
    "z": (3, ["####", "...#", ".##.", "#...", "####"]),
    # Capitals: a careful hand, a few with a lead-in curl (T, J) and a rounded E.
    "A": (1, ["..#..", ".#.#.", ".#.#.", "#...#", "#####", "#...#", "#...#"]),
    "B": (1, ["####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."]),
    "C": (1, [".###.", "#...#", "#....", "#....", "#....", "#...#", ".###."]),
    "D": (1, ["####.", "#...#", "#...#", "#...#", "#...#", "#...#", "####."]),
    "E": (1, [".####", "#....", "#....", "####.", "#....", "#....", ".####"]),
    "F": (1, ["#####", "#....", "#....", "####.", "#....", "#....", "#...."]),
    "G": (1, [".###.", "#...#", "#....", "#.###", "#...#", "#...#", ".###."]),
    "H": (1, ["#...#", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"]),
    "I": (1, ["###", ".#.", ".#.", ".#.", ".#.", ".#.", "###"]),
    "J": (1, [".####", "...#.", "...#.", "...#.", "...#.", "#..#.", ".##.."]),
    "K": (1, ["#...#", "#..#.", "#.#..", "##...", "#.#..", "#..#.", "#...#"]),
    "L": (1, ["#....", "#....", "#....", "#....", "#....", "#....", "#####"]),
    "M": (1, ["#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"]),
    "N": (1, ["#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#", "#...#"]),
    "O": (1, [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."]),
    "P": (1, ["####.", "#...#", "#...#", "####.", "#....", "#....", "#...."]),
    "Q": (1, [".###.", "#...#", "#...#", "#...#", "#.#.#", "#..#.", ".##.#"]),
    "R": (1, ["####.", "#...#", "#...#", "####.", "#.#..", "#..#.", "#...#"]),
    "S": (1, [".####", "#....", "#....", ".###.", "....#", "....#", "####."]),
    "T": (1, ["#####", "#.#..", "..#..", "..#..", "..#..", "..#..", "..#.."]),
    "U": (1, ["#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."]),
    "V": (1, ["#...#", "#...#", "#...#", ".#.#.", ".#.#.", ".#.#.", "..#.."]),
    "W": (1, ["#...#", "#...#", "#...#", "#.#.#", "#.#.#", "##.##", "#...#"]),
    "X": (1, ["#...#", "#...#", ".#.#.", "..#..", ".#.#.", "#...#", "#...#"]),
    "Y": (1, ["#...#", "#...#", ".#.#.", "..#..", "..#..", "..#..", "..#.."]),
    "Z": (1, ["#####", "....#", "...#.", "..#..", ".#...", "#....", "#####"]),
}

# Your own hand: an upright, squared working print, narrow where a letter still reads at 3 px.
YOURS = {
    "a": (3, [".##.", "...#", ".###", "#..#", ".###"]),
    "b": (1, ["#...", "#...", "###.", "#..#", "#..#", "#..#", "###."]),
    "c": (3, [".##", "#..", "#..", "#..", ".##"]),
    "d": (1, ["...#", "...#", ".###", "#..#", "#..#", "#..#", ".###"]),
    "e": (3, [".##", "#.#", "###", "#..", ".##"]),
    "f": (1, [".##", "#..", "###", "#..", "#..", "#..", "#.."]),
    "g": (3, [".###", "#..#", "#..#", "#..#", ".###", "...#", "###."]),
    "h": (1, ["#...", "#...", "###.", "#..#", "#..#", "#..#", "#..#"]),
    "i": (1, ["#", ".", "#", "#", "#", "#", "#"]),
    "j": (1, [".#", "..", ".#", ".#", ".#", ".#", ".#", ".#", "#."]),
    "k": (1, ["#..", "#..", "#.#", "#.#", "##.", "#.#", "#.#"]),
    "l": (1, ["#.", "#.", "#.", "#.", "#.", "#.", "##"]),
    "m": (3, ["####.", "#.#.#", "#.#.#", "#.#.#", "#.#.#"]),
    "n": (3, ["###.", "#..#", "#..#", "#..#", "#..#"]),
    "o": (3, [".##", "#.#", "#.#", "#.#", "##."]),
    "p": (3, ["###.", "#..#", "#..#", "#..#", "###.", "#...", "#..."]),
    "q": (3, [".###", "#..#", "#..#", "#..#", ".###", "...#", "...#"]),
    "r": (3, ["#.##", "##..", "#...", "#...", "#..."]),
    "s": (3, [".##", "#..", ".#.", "..#", "##."]),
    "t": (1, [".#.", ".#.", "###", ".#.", ".#.", ".#.", ".##"]),
    "u": (3, ["#..#", "#..#", "#..#", "#..#", ".###"]),
    "v": (3, ["#.#", "#.#", "#.#", "#.#", ".#."]),
    "w": (3, ["#...#", "#...#", "#.#.#", "#.#.#", ".#.#."]),
    "x": (3, ["#.#", "#.#", ".#.", "#.#", "#.#"]),
    "y": (3, ["#..#", "#..#", "#..#", "#..#", ".###", "...#", "###."]),
    "z": (3, ["###", "..#", ".#.", "#..", "###"]),
    "A": (1, [".##.", "#..#", "#..#", "####", "#..#", "#..#", "#..#"]),
    "B": (1, ["###.", "#..#", "#..#", "###.", "#..#", "#..#", "###."]),
    "C": (1, [".###", "#...", "#...", "#...", "#...", "#...", ".###"]),
    "D": (1, ["###.", "#..#", "#..#", "#..#", "#..#", "#..#", "###."]),
    "E": (1, ["####", "#...", "#...", "###.", "#...", "#...", "####"]),
    "F": (1, ["####", "#...", "#...", "###.", "#...", "#...", "#..."]),
    "G": (1, [".###", "#...", "#...", "#.##", "#..#", "#..#", ".###"]),
    "H": (1, ["#..#", "#..#", "#..#", "####", "#..#", "#..#", "#..#"]),
    "I": (1, ["###", ".#.", ".#.", ".#.", ".#.", ".#.", "###"]),
    "J": (1, ["...#", "...#", "...#", "...#", "...#", "#..#", ".##."]),
    "K": (1, ["#..#", "#..#", "#.#.", "##..", "#.#.", "#..#", "#..#"]),
    "L": (1, ["#...", "#...", "#...", "#...", "#...", "#...", "####"]),
    "M": (1, ["#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"]),
    "N": (1, ["#..#", "##.#", "##.#", "#.##", "#.##", "#..#", "#..#"]),
    "O": (1, [".##.", "#..#", "#..#", "#..#", "#..#", "#..#", ".##."]),
    "P": (1, ["###.", "#..#", "#..#", "###.", "#...", "#...", "#..."]),
    "Q": (1, [".##.", "#..#", "#..#", "#..#", "#..#", "#.##", ".###"]),
    "R": (1, ["###.", "#..#", "#..#", "###.", "#.#.", "#..#", "#..#"]),
    "S": (1, [".###", "#...", "#...", ".##.", "...#", "...#", "###."]),
    "T": (1, ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."]),
    "U": (1, ["#..#", "#..#", "#..#", "#..#", "#..#", "#..#", ".##."]),
    "V": (1, ["#...#", "#...#", "#...#", ".#.#.", ".#.#.", "..#..", "..#.."]),
    "W": (1, ["#...#", "#...#", "#...#", "#.#.#", "#.#.#", "#.#.#", ".#.#."]),
    "X": (1, ["#...#", ".#.#.", ".#.#.", "..#..", ".#.#.", ".#.#.", "#...#"]),
    "Y": (1, ["#...#", "#...#", ".#.#.", "..#..", "..#..", "..#..", "..#.."]),
    "Z": (1, ["####", "...#", "..#.", "..#.", ".#..", "#...", "####"]),
}


def _slant(row: int) -> int:
    """Agnes's lean: the top of the x-height and everything above it one px right, descenders one px left."""
    if row <= 4:
        return 1
    if row >= 9:
        return -1
    return 0


def _cells(glyphs: dict, slanted: bool) -> dict:
    """Each character's pixels as (x, y) on its cell, its cell width and its advance."""
    out = {}
    for ch, (top, rows) in {**COMMON, **glyphs}.items():
        width = max(len(r) for r in rows)
        pixels = []
        for dy, r in enumerate(rows):
            y = top + dy
            for x, c in enumerate(r):
                if c == "#":
                    pixels.append((x + (_slant(y) + 1 if slanted else 0), y))
        # A flick (a last column holding only a baseline pixel) reaches into the gap, so it joins the next letter.
        last = [dy for dy, r in enumerate(rows) if len(r) == width and r[-1] == "#"]
        flick = slanted and ch.islower() and len(last) == 1 and top + last[0] == BASE - 1
        out[ch] = {"pixels": pixels, "w": width + (2 if slanted else 0), "advance": width + (0 if flick else 1),
                   "xoff": -1 if slanted else 0}
    out[" "] = {"pixels": [], "w": 0, "advance": 3, "xoff": 0}
    return out


def build(name: str, glyphs: dict, slanted: bool) -> dict:
    cells = _cells(glyphs, slanted)
    chars = sorted(cells, key=ord)
    # Pack into rows of a 256 px wide sheet, one px apart.
    x = y = 0
    sheet_w = 256
    placed = {}
    for ch in chars:
        c = cells[ch]
        w = max(c["w"], 1)
        if x + w > sheet_w:
            x = 0
            y += ROWS + 1
        placed[ch] = (x, y)
        x += w + 1
    sheet_h = y + ROWS
    sheet_h = 1 << (sheet_h - 1).bit_length()
    img = Image.new("RGBA", (sheet_w, sheet_h), (0, 0, 0, 0))
    for ch in chars:
        ox, oy = placed[ch]
        for px, py in cells[ch]["pixels"]:
            img.putpixel((ox + px, oy + py), (255, 255, 255, 255))
    png = "hand_%s.png" % name
    img.save(os.path.join(OUT, png))
    lines = [
        'info face="Hand %s" size=8 bold=0 italic=%d charset="" unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=1,1' % (name, 1 if slanted else 0),
        "common lineHeight=%d base=%d scaleW=%d scaleH=%d pages=1 packed=0" % (LINE, BASE, sheet_w, sheet_h),
        'page id=0 file="%s"' % png,
        "chars count=%d" % len(chars),
    ]
    for ch in chars:
        c = cells[ch]
        ox, oy = placed[ch]
        lines.append("char id=%d x=%d y=%d width=%d height=%d xoffset=%d yoffset=0 xadvance=%d page=0 chnl=15" % (
            ord(ch), ox, oy, c["w"], ROWS if c["w"] else 0, c["xoff"], c["advance"]))
    with open(os.path.join(OUT, "hand_%s.fnt" % name), "w", newline="\n") as f:
        f.write("\n".join(lines) + "\n")
    return cells


def render(cells: dict, text: str, scale: int, color, width_px: int) -> Image.Image:
    """Sets text in a hand (word-wrapped to width_px native px) for the preview."""
    lines, line = [], ""
    for word in text.split(" "):
        trial = (line + " " + word).strip()
        if sum(cells.get(ch, cells["?"])["advance"] for ch in trial) > width_px and line:
            lines.append(line)
            line = word
        else:
            line = trial
    lines.append(line)
    img = Image.new("RGBA", (width_px * scale, (len(lines) * (LINE + 1) + 1) * scale), (0, 0, 0, 0))
    for li, ln in enumerate(lines):
        pen = 0
        for ch in ln:
            c = cells.get(ch, cells["?"])
            for px, py in c["pixels"]:
                X, Y = pen + px + c["xoff"], li * (LINE + 1) + py
                if 0 <= X < width_px:
                    for i in range(scale):
                        for j in range(scale):
                            img.putpixel((X * scale + i, Y * scale + j), color)
            pen += c["advance"]
    return img


def preview(agnes: dict, yours: dict) -> None:
    out = os.path.join(ROOT, "art", "style_tests", "DIARY-HAND-001", "review")
    os.makedirs(out, exist_ok=True)
    open(os.path.join(out, ".gdignore"), "a").close()
    paper = (198, 172, 126, 255)
    abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz 0123456789 .,;:!?'\"()-/+%&"
    tests = "Il1 rn m cl d oa e c ce vy uv hb gq ij tf 0O 5S 8B"
    agnes_text = "We bought the farm from the town for almost nothing. Elias says the crows are a good sign. I counted forty in the great tree tonight."
    yours_text = "Water the beds before noon. Brush piles give sticks and fibre: 3 sticks make a crude hatchet. Drink at the pond (Space or A)."
    blocks = []
    for cells, ink, text in ((agnes, (61, 36, 20, 255), agnes_text), (yours, (34, 48, 62, 255), yours_text)):
        for t, sc in ((abc, 4), (tests, 4), (text, 2)):
            blocks.append(render(cells, t, sc, ink, 150 if sc == 2 else 120))
    w = max(b.width for b in blocks) + 16
    h = sum(b.height + 8 for b in blocks) + 8
    img = Image.new("RGBA", (w, h), paper)
    y = 8
    for b in blocks:
        img.alpha_composite(b, (8, y))
        y += b.height + 8
    img.save(os.path.join(out, "fonts_preview.png"))
    print("preview:", os.path.join(out, "fonts_preview.png"))


if __name__ == "__main__":
    a = build("agnes", AGNES, True)
    y = build("yours", YOURS, False)
    print("wrote", os.path.join(OUT, "hand_agnes.fnt"), os.path.join(OUT, "hand_yours.fnt"))
    if "preview" in sys.argv:
        preview(a, y)
