"""CCH-WOODWORK-001: placeholder sprites for the workbench and anvil, drawn pixel by pixel from the farm's own
palette (no AI generation). 16 px wide, standing on the foot of their tile like the E3 decor (FarmProjects._stand).
Run from the project folder: python tools/woodwork_art.py  ->  art/farm/e3/workbench.png, art/farm/e3/anvil.png
Temporary art until the stations get their own sprites (see DESIGN.md, "Workbench, anvil and timber")."""
from PIL import Image

INK = (24, 18, 14, 255)
WOOD_D = (70, 49, 37, 255)
WOOD = (118, 80, 57, 255)
WOOD_L = (156, 127, 93, 255)
WOOD_HI = (183, 137, 94, 255)
END = (219, 188, 138, 255)
IRON_D = (43, 45, 48, 255)
IRON = (76, 79, 84, 255)
IRON_L = (123, 131, 132, 255)
HAFT = (173, 133, 90, 255)


def put(img, pts, c):
    for x, y in pts:
        img.putpixel((x, y), c)


def rect(img, x0, y0, x1, y1, c):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            img.putpixel((x, y), c)


def outline(img):
    """A one-pixel dark outline round every filled shape, as the decor sprites have."""
    w, h = img.size
    src = img.copy()
    for y in range(h):
        for x in range(w):
            if src.getpixel((x, y))[3] == 0:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h and src.getpixel((nx, ny))[3] > 0 and src.getpixel((nx, ny)) != INK:
                        img.putpixel((x, y), INK)
                        break


def workbench():
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    # Splayed legs.
    for x, y0 in ((2, 9), (12, 9)):
        rect(img, x, y0, x + 1, 14, WOOD_D)
    put(img, [(3, 10), (13, 10)], WOOD)
    # The split-log top, seen from the front and a little above: a lit top face and a dark front edge.
    rect(img, 1, 6, 14, 7, WOOD_L)
    rect(img, 1, 8, 14, 9, WOOD)
    put(img, [(x, 6) for x in range(2, 14, 3)], WOOD_HI)
    put(img, [(x, 9) for x in range(1, 15)], WOOD_D)
    # A log across it, its cut end showing the rings.
    rect(img, 3, 3, 10, 5, WOOD)
    put(img, [(x, 3) for x in range(3, 10)], WOOD_L)
    rect(img, 11, 3, 12, 5, END)
    put(img, [(11, 4)], WOOD_HI)
    # The hatchet bitten into the log's end.
    put(img, [(12, 0), (12, 1), (12, 2)], HAFT)
    rect(img, 13, 1, 14, 2, IRON_L)
    put(img, [(14, 3)], IRON)
    outline(img)
    return img


def anvil():
    img = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    # The hewn stump it sits on.
    rect(img, 4, 10, 11, 14, WOOD)
    rect(img, 4, 9, 11, 9, END)
    put(img, [(5, 9), (8, 9), (10, 9)], WOOD_HI)
    put(img, [(4, 14), (11, 14), (7, 13)], WOOD_D)
    # The waist, the face and the horn.
    rect(img, 6, 6, 9, 8, IRON_D)
    rect(img, 3, 3, 11, 5, IRON)
    rect(img, 3, 3, 11, 3, IRON_L)
    put(img, [(12, 3), (13, 3), (12, 4), (14, 3)], IRON)
    put(img, [(12, 3), (13, 3)], IRON_L)
    rect(img, 2, 4, 2, 5, IRON_D)
    outline(img)
    return img


if __name__ == "__main__":
    workbench().save("art/farm/e3/workbench.png")
    anvil().save("art/farm/e3/anvil.png")
    print("wrote art/farm/e3/workbench.png, art/farm/e3/anvil.png")
