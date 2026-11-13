#!/usr/bin/env bash
# CCH-PLAYABLE-002: loads a COPY of every save file on this machine in a throwaway profile (slot 1 there), saves it
# again, and compares (tools/audit_save_probe.gd load=1). The owner's files are only read (cp), never opened by the game.
#   bash tools/playable002_oldsaves.sh [scratch_dir]
GODOT="${GODOT:-C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
SCRATCH="${1:-${TMP:-/tmp}/cch002_oldsaves}"
SRC="$APPDATA/Godot/app_userdata"
OUT=art/style_tests/CCH-PLAYABLE-002/logs/save_owner_copies.log
: > "$OUT"
i=0
while IFS= read -r f; do
  i=$((i+1))
  prof="$SCRATCH/p$i"
  rm -rf "$prof"; mkdir -p "$prof/Godot/app_userdata/Crow Creek Hollow"
  cp "$f" "$prof/Godot/app_userdata/Crow Creek Hollow/hallowvale_save_1.json"
  rel="${f#$SRC/}"
  echo "## copy of $rel ($(grep -o '"save_version":[0-9]*' "$f" | head -1), $(wc -c < "$f") bytes)" >> "$OUT"
  APPDATA="$(cygpath -w "$prof")" "$GODOT" --path . --headless -s tools/audit_save_probe.gd -- load=1 2>&1 \
    | grep -E "LOAD|DIFF|SCRIPT ERROR|ERROR|save probe|MSG" | grep -v "shader_gles3\|err != OK" | head -12 >> "$OUT"
done < <(find "$SRC/Crow Creek Hollow" "$SRC/hallowvale" -name 'hallowvale_save_*.json' 2>/dev/null | grep -v '\.bak\|\.tmp')
echo "files: $i" >> "$OUT"
