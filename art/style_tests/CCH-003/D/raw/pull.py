"""Download the farmer character group (every state and animation) into group/: python pull.py"""
import io, zipfile, urllib.request, shutil, os
import sys
CID = sys.argv[1] if len(sys.argv) > 1 else '7beee8bd-88d0-471a-b9e9-5d29ba9695c6'
req = urllib.request.Request('https://api.pixellab.ai/mcp/characters/%s/download' % CID, headers={'User-Agent': 'curl/8'})
data = urllib.request.urlopen(req, timeout=300).read()
if os.path.isdir('group'):
    shutil.rmtree('group')
zipfile.ZipFile(io.BytesIO(data)).extractall('group')
print(len(data), 'bytes')
