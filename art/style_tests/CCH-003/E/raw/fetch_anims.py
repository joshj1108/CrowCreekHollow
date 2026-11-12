"""Downloads every animate_image job in anim_jobs.json into anim/<name>/NN.png (00 = the input frame) and writes
anim_<creature>.png: one row per state at 4x on cave-dark ground. Re-run safely: finished downloads are kept."""
import io, json, os, sys, urllib.request, urllib.error
from PIL import Image, ImageDraw
HERE = os.path.dirname(os.path.abspath(__file__))
jobs = json.load(open(os.path.join(HERE, 'anim_jobs.json'), encoding='utf-8'))
def get(url):
    try:
        with urllib.request.urlopen(url, timeout=60) as r: return r.read()
    except urllib.error.HTTPError as e: return None
only = sys.argv[1:]
for name, (job, seed, n, prompt) in jobs.items():
    if only and not any(name.startswith(o) for o in only): continue
    out = os.path.join(HERE, 'anim', name); os.makedirs(out, exist_ok=True)
    for i in range(n + 1):
        p = os.path.join(out, '%02d.png' % i)
        if os.path.exists(p): continue
        d = get('https://api.pixellab.ai/mcp/images/%s/download?index=%d' % (job, i))
        if d is None: print('missing', name, i); break
        Image.open(io.BytesIO(d)).convert('RGBA').save(p)
for c in ['bat', 'lizard', 'snake']:
    rows = [k for k in jobs if k.startswith(c + '_')]
    s = 4; cw = 32 * s + 6
    sheet = Image.new('RGBA', (90 + 7 * cw, len(rows) * (32 * s + 6)), (30, 28, 26, 255)); dr = ImageDraw.Draw(sheet)
    for r, k in enumerate(rows):
        dr.text((4, r * (32 * s + 6) + 10), k, fill=(230, 220, 190, 255))
        d = os.path.join(HERE, 'anim', k)
        if not os.path.isdir(d): continue
        for i, f in enumerate(sorted(os.listdir(d))):
            im = Image.open(os.path.join(d, f)).convert('RGBA')
            sheet.alpha_composite(im.resize((32 * s, 32 * s), Image.NEAREST), (90 + i * cw, r * (32 * s + 6)))
    sheet.save(os.path.join(HERE, 'anim_%s.png' % c))
print('ok')
