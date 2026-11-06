"""Download every candidate of a PixelLab create_image_pro job into raw/<name>/NN.png and a numbered grid sheet."""
import sys, os, urllib.request, io
from concurrent.futures import ThreadPoolExecutor
from PIL import Image, ImageDraw
job, name, n = sys.argv[1], sys.argv[2], int(sys.argv[3])
cols = int(sys.argv[4]) if len(sys.argv) > 4 else 8
out = os.path.join(os.path.dirname(__file__), '..', 'raw', name); os.makedirs(out, exist_ok=True)
def get(i):
    data = urllib.request.urlopen(f'https://api.pixellab.ai/mcp/images/{job}/download?index={i}').read()
    open(os.path.join(out, '%02d.png' % i), 'wb').write(data)
    return Image.open(io.BytesIO(data)).convert('RGBA')
with ThreadPoolExecutor(8) as ex:
    ims = list(ex.map(get, range(n)))
w, h = ims[0].size; S = 3; pad = 10
rows = (n + cols - 1) // cols
sheet = Image.new('RGBA', (cols * (w * S + 4), rows * (h * S + pad + 4)), (70, 78, 58, 255))
d = ImageDraw.Draw(sheet)
for i, im in enumerate(ims):
    x, y = (i % cols) * (w * S + 4), (i // cols) * (h * S + pad + 4)
    sheet.alpha_composite(im.resize((w * S, h * S), Image.NEAREST), (x + 2, y + pad))
    d.text((x + 2, y), str(i), fill=(255, 255, 200, 255))
sheet.save(os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '..', 'builds', 'review', 'aohB', name + '_sheet.png'))
print(name, n, sheet.size)
