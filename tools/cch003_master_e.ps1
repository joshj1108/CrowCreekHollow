# CCH-CONSOLIDATED-003 Phase E: the review masters (tools/review_master.ps1) from the sheets and frame grids made by
# tools/cch003_review_e.py and tools/cch003_motion_e.ps1.
#   & .\tools\cch003_master_e.ps1
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot)
$R = 'art/style_tests/CCH-003/review'
$sum = 'Phase E: the cave bat, lizard and snake redrawn in PixelLab as real cave animals (muted hides, small dark eyes, no glow) at their old size, each with idle, move, alert, attack, hurt and death. Art only: HP, speed, aggro, cooldowns, damage, spawns, drops and saves unchanged.'
& "$PSScriptRoot\review_master.ps1" -Out "$R/CCH-003-E_master.png" -Task 'CCH-003-E (1/4)' -Summary $sum `
    -Sheets "$R/E_old_new.png", "$R/E_scenes.png" `
    -Captions 'Old vs new at native size, 3x and 6x', 'In the cave, BEFORE / AFTER: no lantern, tiers 1-3, the exit at noon'
& "$PSScriptRoot\review_master.ps1" -Out "$R/CCH-003-E_master_2.png" -Task 'CCH-003-E (2/4)' -Summary $sum `
    -Sheets "$R/E_strips.png", "$R/E_states.png" `
    -Captions 'Every state, every frame (4x and native)', 'Each state in the cave (upgraded lantern)'
& "$PSScriptRoot\review_master.ps1" -Out "$R/CCH-003-E_master_3.png" -Task 'CCH-003-E (3/4)' -Summary $sum `
    -Sheets "$R/E_after_bat_frames.png", "$R/E_after_lizard_frames.png", "$R/E_after_snake_frames.png" `
    -Captions 'AFTER bat: alert, strike, two hits, the fall', 'AFTER lizard: alert, strike, two hits, the fall', 'AFTER snake: alert, strike, two hits, the fall'
& "$PSScriptRoot\review_master.ps1" -Out "$R/CCH-003-E_master_4.png" -Task 'CCH-003-E (4/4)' -Summary $sum `
    -Sheets "$R/E_before_bat_frames.png", "$R/E_before_lizard_frames.png", "$R/E_before_snake_frames.png" `
    -Captions 'BEFORE bat (same clip, old sheets: vanishes on the kill)', 'BEFORE lizard', 'BEFORE snake'
