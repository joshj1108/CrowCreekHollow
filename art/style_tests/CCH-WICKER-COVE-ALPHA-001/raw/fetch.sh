#!/bin/sh
# key job_id count
get() { mkdir -p "$1"; i=0; while [ $i -lt $3 ]; do curl -sS -o "$1/$(printf %02d $i).png" "https://api.pixellab.ai/mcp/images/$2/download?index=$i"; i=$((i+1)); done; }
get store edac2571-8d1a-49e1-85d1-cd2f0e9c7cd6 4
get inn 855e6349-fe2b-4ebc-bb1b-770873519a54 4
get cottage e95b055e-9fc9-4a15-8bc8-95aab9363023 4
get market 3d9a102a-626e-47ab-9cd0-608f3ce83f08 4
get boat 0ea6238a-f29b-4ced-a6bc-98f6a5060d9f 16
get props d8885670-40c5-441e-9e19-92f548aeca18 4
get thomas 998477df-5b3a-4100-a2b0-3d34aa225b25 64
get edith a86c164d-f453-46f6-8d3e-0f236356a1aa 64
