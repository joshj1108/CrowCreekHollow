# ART-005 M0/M1 review panels (non-production): the architectural coordinate overlay, 1:1 crops, the c1 vs anchor v2
# comparison and the extension-clearance sheet. Reads pl/g2/ (tools/art005_m0.py, tools/art005_m1.py) and writes
# PNGs to pl/g2/review/. The harness captures and the BEFORE/AFTER sheet are made separately (see the board post).
#   python tools/art005_m0_review.py
import json
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "style_tests", "ART-005")
G2 = os.path.join(ROOT, "pl", "g2")
REV = os.path.join(G2, "review")
BG = (28, 30, 34)
FG = (232, 232, 228)
F = ImageFont.load_default(size=15)
FS = ImageFont.load_default(size=12)
FB = ImageFont.load_default(size=20)


def img(p):
    return Image.open(os.path.join(G2, p)).convert("RGBA")


def up(im, k):
    return im.resize((im.width * k, im.height * k), Image.NEAREST)


def on(bg, im, xy):
    bg.paste(im, xy, im)


def overlay(anc):
    A = anc["anchors"]
    E = anc["extensions_proposed"]
    k = 3
    cw, ch = 384, 352
    house = img("32/house_day.png")
    base = Image.new("RGBA", (cw, ch), (70, 78, 60, 255))
    on(base, house, (0, 0))
    arr = np.array(base).astype(float)
    arr[..., :3] = arr[..., :3] * 0.45 + 30
    base = up(Image.fromarray(arr.astype(np.uint8)), k)
    ml, mt, mr = 60, 40, 420
    W, H = cw * k + ml + mr, ch * k + mt + 30
    out = Image.new("RGBA", (W, H), BG + (255,))
    out.paste(base, (ml, mt))
    d = ImageDraw.Draw(out)
    X = lambda x: ml + x * k
    Y = lambda y: mt + y * k
    for t in range(13):
        d.line([X(t * 32), Y(0), X(t * 32), Y(ch)], fill=(90, 90, 90), width=1)
        d.text((X(t * 32) + 2, 22), str(t * 32), font=FS, fill=(160, 160, 160))
    for t in range(12):
        d.line([X(0), Y(t * 32), X(cw), Y(t * 32)], fill=(90, 90, 90), width=1)
        d.text((4, Y(t * 32) - 6), str(t * 32), font=FS, fill=(160, 160, 160))
    d.rectangle([X(0), Y(320), X(cw), Y(ch)], outline=(120, 120, 120))
    d.text((X(4), Y(322)), "below the 384x320 house canvas (porch row continues to y 330)", font=FS, fill=(170, 170, 170))
    fp = A["footprint"]
    # collision bands
    cy = (80, 200, 230)
    d.rectangle([X(16), Y(74), X(368), Y(298)], outline=cy, width=3)
    d.line([X(16), Y(234), X(368), Y(234)], fill=cy, width=1)
    d.rectangle([X(16), Y(298), X(368), Y(330)], outline=(80, 200, 230), width=1)
    # overhang
    for x0, x1 in (A["overhang"]["west"], A["overhang"]["east"]):
        for yy in range(int(Y(0)), int(Y(160)), 9):
            d.line([X(x0), yy, X(x1), yy + 12], fill=(200, 200, 90), width=1)
    yl = (240, 210, 70)
    for y, lab in ((20, "ridge y20"), (148, "eave band 148-160"), (160, "eave y160"), (298, "wall base y298")):
        d.line([X(0), Y(y), X(cw), Y(y)], fill=yl, width=2)
    # door, steps
    mg = (240, 90, 220)
    dx, dy = A["door"]["x"], A["door"]["y"]
    d.rectangle([X(dx[0]), Y(dy[0]), X(dx[1]), Y(dy[1])], outline=mg, width=3)
    d.line([X(192), Y(200), X(192), Y(330)], fill=mg, width=1)
    s = A["steps"]
    d.rectangle([X(s["tread2_x"][0]), Y(298), X(s["tread2_x"][1]), Y(320)], outline=mg, width=1)
    # windows and lights
    gr = (90, 230, 120)
    for w in A["windows"]:
        d.rectangle([X(w["x"][0]), Y(w["y"][0]), X(w["x"][1]), Y(w["y"][1])], outline=gr, width=3)
    L = A["lights"]
    for x, y in L["intended_HOUSE_SPRITE_WINDOWS"]:
        d.ellipse([X(x) - 9, Y(y) - 9, X(x) + 9, Y(y) + 9], outline=(255, 255, 255), width=3)
    for x, y in L["e1_harness"]:
        d.line([X(x) - 7, Y(y) - 7, X(x) + 7, Y(y) + 7], fill=(255, 150, 40), width=3)
        d.line([X(x) - 7, Y(y) + 7, X(x) + 7, Y(y) - 7], fill=(255, 150, 40), width=3)
    for x, y in L["production_measured"] + L["production_measured_with_spill"]:
        d.ellipse([X(x) - 8, Y(y) - 8, X(x) + 8, Y(y) + 8], outline=(255, 60, 60), width=3)
    # chimney, dormer zone
    c = A["chimney"]
    d.rectangle([X(c["cap_x"][0]), Y(0), X(c["cap_x"][1]), Y(c["y"][1])], outline=(90, 220, 255), width=2)
    dz = A["dormer_zone_production"]
    g = dz["outline_grow"]
    d.rectangle([X(dz["wall"][0] - g), Y(dz["gable_apex"][1] - g), X(dz["wall"][2] + g), Y(dz["wall"][3] + g)],
                outline=(110, 140, 255), width=3)
    # porch: production (red, dashed) and proposed (orange)
    pp = A["porch_production"]
    for r in [pp["deck"], pp["roof"]] + pp["posts"]:
        x0, y0, x1, y1 = r
        for i in range(int(X(x0)), int(X(x1)), 10):
            d.line([i, Y(y0), min(i + 5, X(x1)), Y(y0)], fill=(255, 60, 60), width=2)
            d.line([i, Y(y1), min(i + 5, X(x1)), Y(y1)], fill=(255, 60, 60), width=2)
        d.line([X(x0), Y(y0), X(x0), Y(y1)], fill=(255, 60, 60), width=2)
        d.line([X(x1), Y(y0), X(x1), Y(y1)], fill=(255, 60, 60), width=2)
    pz = E["porch"]
    for key in ("roof", "fascia", "deck", "deck_front"):
        x0, y0, x1, y1 = pz[key]
        d.rectangle([X(x0), Y(y0), X(x1), Y(y1)], outline=(255, 170, 60), width=1)
    for x0, x1 in pz["posts"]:
        d.rectangle([X(x0), Y(pz["post_y"][0]), X(x1), Y(pz["post_y"][1])], outline=(255, 170, 60), width=1)
    # legend
    lx = ml + cw * k + 16
    items = [
        ((80, 200, 230), "Collision footprint x16-368: roof rows y74-234,"),
        (None, "   wall rows y234-298 (11 x 7 tiles); porch row y298-330"),
        ((200, 200, 90), "Roof overhang x0-16 and x368-384 (roof only)"),
        (yl, "Ridge y20 · eave band 148-160 · eave y160 · base y298"),
        (mg, "Door 38x74 at x173-211, y224-298; centre x192;"),
        (None, "   steps x160-224, y298-320 on the door tile"),
        (gr, "Windows 45x45, centres (96,224) and (286,224)"),
        ((255, 255, 255), "Light: HOUSE_SPRITE_WINDOWS (the intended centres)"),
        ((255, 150, 40), "Light: E1 harness for art=ph/pl (+-3.1, -2.8 tiles)"),
        ((255, 60, 60), "Light: production as measured (y298; y330 w/ spill)"),
        ((90, 220, 255), "Chimney + cap x297-331, y0-52"),
        ((110, 140, 255), "Production dormer zone x94-290, y59-127"),
        ((255, 60, 60), "Production porch geometry (dashed)"),
        ((255, 170, 60), "Proposed 32px porch (outlines)"),
    ]
    y = mt
    d.text((lx, y), "M0 architectural coordinates", font=FB, fill=FG)
    y += 32
    d.text((lx, y), "art px at 32 px/tile, sprite top-left = 0,0", font=FS, fill=(180, 180, 180))
    y += 26
    for col, t in items:
        if col:
            d.rectangle([lx, y + 3, lx + 14, y + 15], outline=col, width=3)
        d.text((lx + 22, y), t, font=FS, fill=FG)
        y += 22
    y += 12
    notes = [
        "Clearances (px):",
        " chimney cap x297 vs dormer zone x290: 7",
        " dormer apex y59 vs ridge y20: 39 below",
        " dormer zone vs eave band y148: 21",
        " window glass vs light (white ring): 0",
        " door centre vs door tile centre x192: 0",
        " footprint vs eave overhang: 16 each side",
        "",
        "Production light offset (measured, not changed):",
        " main.gd _build_window_lights adds the window",
        " centres to the footprint's top-left (map row 5),",
        " not to the sprite's top (2.3125 tiles higher),",
        " so the lights fall 74 px below the glass (+32",
        " WINDOW_SPILL). Flagged only; lighting untouched.",
    ]
    for t in notes:
        d.text((lx, y), t, font=FS, fill=FG)
        y += 18
    out.convert("RGB").save(os.path.join(REV, "m0_overlay_coords.png"))


def crops():
    house = img("32/house_day.png")
    v2 = img("m0/house_day_v2mat.png")
    regs = [("roof + chimney", (240, 0, 384, 112)), ("window (west)", (64, 192, 128, 256)),
            ("door + lamp + steps", (152, 212, 240, 320)), ("foundation + corner", (0, 264, 128, 320))]
    k = 4
    pad = 16
    colw = max((r[2] - r[0]) for _, r in regs) * k
    W = pad + (colw + pad) * 2 + 40
    rows_h = sum((r[3] - r[1]) * k + 40 + (r[3] - r[1]) + 10 for _, r in regs)
    out = Image.new("RGBA", (W + 300, rows_h + 90), BG + (255,))
    d = ImageDraw.Draw(out)
    d.text((pad, 10), "1:1 crops (small) and the same crops enlarged 4x (nearest neighbour, for inspection only)", font=F, fill=FG)
    d.text((pad, 32), "Left: M0 skinned with G1 c1 materials (the mockup in the harness).  Right: same blockout skinned with M1 anchor v2 (comparison only).", font=FS, fill=(190, 190, 190))
    y = 60
    for name, (x0, y0, x1, y1) in regs:
        d.text((pad, y), f"{name}: sprite px x{x0}-{x1}, y{y0}-{y1}", font=F, fill=FG)
        y += 22
        for i, src in enumerate((house, v2)):
            cr = src.crop((x0, y0, x1, y1))
            bgc = Image.new("RGBA", cr.size, (70, 78, 60, 255))
            on(bgc, cr, (0, 0))
            x = pad + i * (colw + pad)
            out.paste(bgc, (x, y))
            out.paste(up(bgc, k), (x, y + (y1 - y0) + 8))
        y += (y1 - y0) * (k + 1) + 26
    out = out.crop((0, 0, W, y))
    out.convert("RGB").save(os.path.join(REV, "m0_crops_1to1.png"))


def anchors_compare():
    c1 = Image.open(os.path.join(ROOT, "pl", "anchors", "board_c1.png")).convert("RGBA")
    v2 = img("m1/anchor_v2.png")
    df = img("m1/anchor_v2_diff.png")
    log = json.load(open(os.path.join(G2, "m1", "m1_log.json")))
    k = 6
    pad = 20
    W = pad + (96 * k + pad) * 3
    out = Image.new("RGBA", (W, 96 * k + 700), BG + (255,))
    d = ImageDraw.Draw(out)
    for i, (im, t) in enumerate(((c1, "c1 original (G1, frozen; unchanged)"), (v2, "anchor_v2 (M1, new file)"),
                                 (df, "changed pixels (magenta)"))):
        x = pad + i * (96 * k + pad)
        d.text((x, 10), t, font=F, fill=FG)
        out.paste(up(im, k), (x, 34))
        out.paste(im, (x, 34 + 96 * k + 8))
    b = log["board"]
    y = 34 + 96 * k + 112
    lines = [
        f"Board: orphan pixels {b['orphans_before']:.2%} -> {b['orphans_after']:.2%} (gate <= 3%); colours {b['colours_before']} -> {b['colours_after']}; "
        f"pixels changed {b['changed_px']} of {b['of_px']} ({b['changed_px'] / b['of_px']:.0%}); palette 100% E0 before and after.",
        "Steps per 32 px swatch: 1 merge near-duplicate colours into the swatch's own G1 colours (no new colour), "
        "2 orphans take their neighbours' majority,",
        "3 clusters under 4 px (less than a 2x2 mark) join their surroundings, except the darkest-tone lines >= 3 px "
        "(mortar, course and plank seams, outlines); 4 manual edits.",
        "Manual edits: 4, 63 px, all in the window: the mullion's lit row and three panes' 1 px glints restored "
        "from c1 (step 3 read deliberate glints as noise).",
        "Not changed: mark sizes. c1's slate courses repeat every ~8 px and its stone every ~9-11 px (spec: 16 px "
        "courses, 10-16 px blocks); anchor_v2 keeps them.",
    ]
    for t in lines:
        d.text((pad, y), t, font=FS, fill=FG)
        y += 20
    rows = [("swatch (steps 1-3)", "colours", "orphans", "px changed")]
    for n, r in log["swatches"].items():
        rows.append((n, f"{r['colours_before']} -> {r['colours_after']}", f"{r['orphans_before']:.1%} -> {r['orphans_after']:.1%}",
                     str(r["changed_px_total"])))
    y += 6
    for j, r in enumerate(rows):
        for i, t in enumerate(r):
            d.text((pad + i * 170 + (j // 6) * 0, y), t, font=FS, fill=FG if j else (200, 200, 120))
        y += 17
    out = out.crop((0, 0, W, y + 10))
    out.convert("RGB").save(os.path.join(REV, "m1_c1_vs_anchor_v2.png"))


def clearance(anc):
    A = anc["anchors"]
    k = 2
    pad = 20
    combos = [("base house (stage art only)", []), ("+ dormer (production geometry)", ["ext_dormer_day"]),
              ("+ proposed porch", ["ext_porch_day"]), ("+ both", ["ext_dormer_day", "ext_porch_day"])]
    tw, th = 384 * k, 336 * k
    W = pad + (tw + pad) * 2
    out = Image.new("RGBA", (W, (th + 40) * 2 + 330), BG + (255,))
    d = ImageDraw.Draw(out)
    for i, (t, layers) in enumerate(combos):
        cvs = Image.new("RGBA", (384, 336), (70, 78, 60, 255))
        on(cvs, img("32/house_day.png"), (0, 0))
        for l in layers:
            on(cvs, img("32/" + l + ".png"), (0, 0))
        x = pad + (i % 2) * (tw + pad)
        y = 30 + (i // 2) * (th + 40)
        d.text((x, y - 22), t, font=F, fill=FG)
        out.paste(up(cvs, k), (x, y))
        if i == 3:
            dd = ImageDraw.Draw(out)
            P = lambda px, py: (x + px * k, y + py * k)
            pp = A["porch_production"]
            for r in [pp["deck"], pp["roof"]] + pp["posts"]:
                dd.rectangle([P(r[0], r[1]), P(r[2], r[3])], outline=(255, 60, 60), width=2)
    y = 30 + 2 * (th + 40)
    lines = [
        "Dormer (production geometry from estate_system.gd, re-skinned): wall x96-288 y96-125, gable apex y61; sits wholly on the roof plane;",
        "  7 px clear of the chimney cap (x297), 39 px below the ridge, 21 px above the eave band. Its 16x15 windows are below the mark scale (glass panes",
        "  of the house are 15 px each, inside 45 px windows): a production-geometry limit, flagged, not redesigned here.",
        "Proposed porch (new 32 px geometry, own 384x336 layer): shed roof y164-194 + fascia y194-200, posts at x24, 136, 240, 352 (8 px), deck y298-322 in",
        "  the porch row, front edge y322-330, centre step x164-220. Clearances: window frames (y202) 2 px below the fascia, glass 8 px; door trim (y218) 18 px;",
        "  nearest posts 16 px from a window frame and 23 px from the door trim; house eave (y160) 4 px above the porch roof; nothing outside the porch row",
        "  except the roof and posts against the wall. It covers the house's base steps (the deck replaces them).",
        "Production porch geometry (red, bottom right, as estate_system.gd draws it today): its roof strip y287-294 crosses the door opening (y224-298) and",
        "  the foundation; its deck y316-328 overlaps the steps by 4 px; its posts x19-23 / x361-365 sit on the corner posts. That code-drawn porch would need",
        "  the proposed geometry (or another) before any 32 px house ships. Not changed here: production, estate_system.gd and layout are untouched.",
    ]
    for t in lines:
        d.text((pad, y), t, font=FS, fill=FG)
        y += 19
    out = out.crop((0, 0, W, y + 10))
    out.convert("RGB").save(os.path.join(REV, "m0_extension_clearance.png"))


def main():
    os.makedirs(REV, exist_ok=True)
    anc = json.load(open(os.path.join(G2, "m0", "anchors.json")))
    overlay(anc)
    crops()
    anchors_compare()
    clearance(anc)
    for f in sorted(x for x in os.listdir(REV) if x.endswith(".png")):
        print(f, Image.open(os.path.join(REV, f)).size)


if __name__ == "__main__":
    main()
