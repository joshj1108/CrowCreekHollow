# CCH-CONSOLIDATED-003 Phase E: GIFs (and frame grids) of the cave creatures from the running game, via
# tools/review_motion.ps1. Each clip: one creature starts 2.15 tiles right of the farmer (iron sword, upgraded
# lantern), notices him (alert), closes in and strikes (attack; the farmer flinches), then takes two sword hits
# (hurt flash) and dies on the third (the fall). chp=13: the iron sword deals 6. BEFORE draws the old sheets, where
# a kill vanished at once.
#   & .\tools\cch003_motion_e.ps1
$ErrorActionPreference = 'Stop'
$R = 'art/style_tests/CCH-003/review'
$walk = 'walk=wait:1.6,use:0.55,use:0.55,use:1.5'
foreach ($k in 'bat', 'lizard', 'snake') {
    $o = "cave ctile=16,19 face=right weapon=iron_sword lantern=3 creatures=live ckinds=$k chp=13 $walk"
    & "$PSScriptRoot\review_motion.ps1" -Out "$R/E_after_$k" -Opts $o -Secs 4.2 -Crop '400:200' -Frames 12 -Every 8
    & "$PSScriptRoot\review_motion.ps1" -Out "$R/E_before_$k" -Opts "$o oldfoes" -Secs 4.2 -Crop '400:200' -Frames 12 -Every 8
}
