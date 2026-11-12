# CCH-CONSOLIDATED-003 Final Polish: the review package's GIFs (and frame grids), recorded from this build through
# tools/review_motion.ps1 (Movie Maker, 30 fps of game time). The combat clips run capture.gd's combatlog, and the
# COMBAT timing lines are written beside each clip (<clip>_timing.txt). Run from the repository root:
#   & .\tools\cchfp_motion.ps1            (all clips)   & .\tools\cchfp_motion.ps1 -Only combat,block
param([string[]] $Only = @())
$ErrorActionPreference = 'Stop'
$R = 'art/style_tests/CCH-003-FP/review'
$clips = [ordered]@{
    # Sword hits on a lizard: it notices and strikes, then three swings land on their contact frames; the third kills.
    'combat' = @{ o = 'cave ctile=16,19 face=right weapon=iron_sword lantern=3 creatures=live ckinds=lizard chp=13 combatlog walk=wait:1.3,use:0.55,use:0.55,use:1.5'; s = 4.2; c = '400:200' }
    # The bat's dive, then two hits and the fall.
    'combat_bat' = @{ o = 'cave ctile=16,19 face=right weapon=copper_sword lantern=3 creatures=live ckinds=bat chp=9 combatlog walk=wait:1.6,use:0.55,use:0.55,use:1.5'; s = 4.2; c = '400:200' }
    # Guarding: a blow from the front is turned aside (jolt, chips); one from behind lands; a swing while holding the
    # guard drops it, so a blow then lands (mistimed); then the farmer walks off, back to normal movement.
    'block' = @{ o = 'tile=50,30 face=right hour=12 weather=sunny weapon=iron_sword combatlog walk=block+blow:1.0,wait:0.4,block+blowback:1.0,wait:0.4,use+block+blow:1.0,right:0.8'; s = 4.6; c = '300:220' }
    # Lantern at night: walking with it in hand, a sword swing and the guard (it goes to the belt), then walking on.
    'lantern_combat' = @{ o = 'tile=50,30 face=right hour=21.5 weather=cloudy lantern=2 weapon=iron_sword walk=right:0.8,use:0.6,block:0.8,right:0.9'; s = 3.2; c = '360:260' }
    # Watering facing down: the stream is water now.
    'water' = @{ o = 'tile=50,30 face=down hour=12 weather=sunny slot=5 walk=use:0.7,use:0.7,wait:0.4'; s = 1.8; c = '300:240' }
}
foreach ($k in $clips.Keys) {
    if ($Only.Count -and -not ($Only -contains $k)) { continue }
    $c = $clips[$k]
    $log = & "$PSScriptRoot\review_motion.ps1" -Out "$R/FP_$k" -Opts $c.o -Secs $c.s -Crop $c.c -Frames 12 -Every ([int][math]::Floor($c.s * 30 / 12))
    $lines = @($log | Where-Object { "$_" -like 'COMBAT*' })
    if ($lines.Count) { $lines | Set-Content -Encoding utf8 "$R/FP_${k}_timing.txt" }
    $log | Where-Object { "$_" -notlike 'COMBAT*' }
}
