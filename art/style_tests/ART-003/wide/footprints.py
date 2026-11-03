# Which landmarks one gameplay screen shows from each viewpoint: the share of each landmark's sprite extent
# (its art, not its collision footprint) inside a 1280x720 view, 26.67 x 15 tiles centred on the farmer.
VW, VH = 1280 / 48, 720 / 48
marks = {   # sprite extents in inner-farm tiles: x0, y0, x1, y1
    'Farmhouse (12x10 sprite)': (39.5, 1.0, 51.5, 11.0),
    'Ancient oak (12x12 sprite)': (24.5, 2.0, 36.5, 14.0),
    'Well (2x3 sprite)': (37.0, 14.0, 39.0, 17.0),
    'Garden (fenced 19x13)': (42.0, 18.0, 61.0, 31.0),
    'Orchard (fenced 16x11)': (6.0, 17.0, 22.0, 28.0),
    'Pond and dock': (3.0, 29.0, 19.0, 37.0),
}
views = {
    'V1 homestead core (37.5, 9.5)': (37.5, 9.5),
    'V2 garden (49.0, 24.0)': (49.0, 24.0),
    'V3 arrival from the south-west (31.0, 19.0)': (31.0, 19.0),
    'V4 orchard and pond (14.0, 27.5)': (14.0, 27.5),
    'V5 porch (45.0, 12.5)': (45.0, 12.5),
}
def share(m, v):
    x0, y0, x1, y1 = m; cx, cy = v
    vx0, vy0, vx1, vy1 = cx - VW / 2, cy - VH / 2, cx + VW / 2, cy + VH / 2
    ix = max(0.0, min(x1, vx1) - max(x0, vx0)); iy = max(0.0, min(y1, vy1) - max(y0, vy0))
    return ix * iy / ((x1 - x0) * (y1 - y0))
print('| View (farmer at) | ' + ' | '.join(k.split(' (')[0] for k in marks) + ' |')
print('| --- |' + ' --- |' * len(marks))
for vn, v in views.items():
    print(f'| {vn} | ' + ' | '.join(f'{share(m, v) * 100:.0f}%' for m in marks.values()) + ' |')
x0 = min(m[0] for m in marks.values()); y0 = min(m[1] for m in marks.values())
x1 = max(m[2] for m in marks.values()); y1 = max(m[3] for m in marks.values())
print(f'\nAll six landmarks span x {x0}-{x1}, y {y0}-{y1}: {x1-x0:.1f} x {y1-y0:.1f} tiles = {(x1-x0)/VW:.2f} x {(y1-y0)/VH:.2f} screens ({(x1-x0)*(y1-y0)/(VW*VH):.1f} screens of area).')
core = [marks['Farmhouse (12x10 sprite)'], marks['Ancient oak (12x12 sprite)'], marks['Well (2x3 sprite)']]
print(f"Oak + house + well span {max(m[2] for m in core)-min(m[0] for m in core):.1f} x {max(m[3] for m in core)-min(m[1] for m in core):.1f} tiles (one screen is {VW:.2f} x {VH:.1f}).")
