#!/usr/bin/env bash
# ART-005 E1: runs every capture of the density test (non-production) into builds/review/ART-005/ (gitignored),
# then tools/art005_report.py turns them into the review package. Reproduce with:
#   bash tools/art005_run.sh [stills|ui|probe|walk|swing|perf|all]
# perf runs one case at a time with nothing else rendering, so its numbers are not disturbed.
set -u
cd "$(dirname "$0")/.."
G="${GODOT:-/c/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
O=builds/review/ART-005
WHAT="${1:-all}"
COLS=("density=16 art=a" "density=16" "density=32" "density=64")
RES=1280x720,1920x1080,2560x1440,3840x2160

run() { "$G" --path . -s tools/art005_density.gd -- "$@" 2>&1 | grep -E "ART005|ERROR|SCRIPT" ; }

if [[ $WHAT == all || $WHAT == stills ]]; then
  for c in "${COLS[@]}"; do for h in 12 21.5; do for fr in int fill today; do
    run $c hour=$h framing=$fr task=stills res=$RES out=$O/stills
  done; done; done
fi
if [[ $WHAT == all || $WHAT == ui ]]; then
  for c in "density=16 art=a" "density=32" "density=64"; do
    run $c hour=21.5 task=stills ui=screen res=1920x1080,3840x2160 native=0 out=$O/ui
  done
  run density=16 art=a hour=21.5 task=stills ui=world res=1920x1080 native=0 out=$O/ui
  run density=64 hour=21.5 task=stills ui=world res=1920x1080 native=0 out=$O/ui
fi
if [[ $WHAT == all || $WHAT == probe ]]; then
  for d in 16 32 64; do
    for r in 1280x720 1920x1080 2560x1440 3840x2160; do
      run density=$d task=probe framing=int camera=smooth res=$r out=$O/probe
      run density=$d task=probe framing=today res=$r out=$O/probe
    done
  done
fi
if [[ $WHAT == all || $WHAT == walk ]]; then
  for c in "density=16 art=a" "density=32" "density=64"; do
    run $c task=walk framing=int camera=smooth fps=50 frames=150 skip=20 out=$O/walk
    run $c task=walk framing=int camera=smooth fps=50 frames=150 skip=20 hour=21.5 out=$O/walk
    run $c task=walk framing=today fps=50 frames=150 skip=20 out=$O/walk
    run $c task=walk framing=int camera=snap fps=50 frames=150 skip=20 out=$O/walk
  done
  run density=16 art=a task=walk framing=int camera=smooth fps=50 frames=150 skip=20 hour=21.5 lantern=stepped out=$O/walk
  # metrics only (tiny crops): a 144 Hz display, every camera mode
  for d in 16 32 64; do for cm in smooth snap free; do
    run density=$d task=walk framing=int camera=$cm fps=144 frames=432 skip=0 crop=8x8 out=$O/walk144
  done; done
fi
if [[ $WHAT == all || $WHAT == swing ]]; then
  for c in "density=16 art=a" "density=32" "density=64"; do
    run $c task=swing framing=int camera=smooth hour=21.5 fps=50 frames=80 crop=320x180 out=$O/swing
    run $c task=swing framing=int camera=smooth hour=21.5 fps=50 frames=80 crop=320x180 lantern=stepped out=$O/swing
  done
fi
if [[ $WHAT == all || $WHAT == perf ]]; then
  for c in "density=16 art=a" "density=16" "density=32" "density=64"; do
    for r in 1920x1080 3840x2160; do
      run $c task=perf framing=int camera=smooth hour=21.5 res=$r secs=8 out=$O/perf
      run $c task=perf framing=today hour=21.5 res=$r secs=8 out=$O/perf
    done
  done
fi
