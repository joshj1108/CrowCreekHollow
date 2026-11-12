"""Download every candidate of a PixelLab image job: python fetch.py <key> <job_id> <n>"""
import sys, os, urllib.request
key, job, n = sys.argv[1], sys.argv[2], int(sys.argv[3])
os.makedirs(key, exist_ok=True)
for i in range(n):
    url = 'https://api.pixellab.ai/mcp/images/%s/download?index=%d' % (job, i)
    try:
        data = urllib.request.urlopen(url, timeout=60).read()
    except Exception as e:
        print(i, e); break
    open(os.path.join(key, '%02d.png' % i), 'wb').write(data)
with open('jobs.txt', 'a', encoding='utf-8', newline='') as f:
    f.write('%s %s\n' % (key, job))
