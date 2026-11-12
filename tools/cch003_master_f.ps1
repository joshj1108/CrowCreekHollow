# CCH-CONSOLIDATED-003 Phase F: the final package's masters 1-11 (tools/review_master.ps1), from the sheets of
# tools/cch003_review_f.py, the clips of tools/cch003_motion_f.ps1, and the reference sheets of Phases C-E
# (clipping audit, furniture and farmer old vs new, every animation strip), which still show the final build.
#   & .\tools\cch003_master_f.ps1
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot)
$R = 'art/style_tests/CCH-003/review'
$T = 'CCH-003 final'
$sum = 'CCH-CONSOLIDATED-003 final package (Phases A-F): survival HUD without numbers, developer world-state panel, mail at an outdoor mailbox (desk light gone), farmhouse furniture family and layout, the new farmer with every animation and the lantern in hand or on the belt, the new cave creatures. BEFORE = b1e8235 (the commit before Phase A), AFTER = the final build; all from the running game. Mechanics, balance, timings and saves unchanged.'
function M([string] $n, [string] $what, [string[]] $sheets, [string[]] $caps) {
    & "$PSScriptRoot\review_master.ps1" -Out "$R/CCH-003-F_master_$n.png" -Task "$T $n/11 $what" -Summary $sum -Sheets $sheets -Captions $caps
}
M '1' 'HUD' @("$R/F_sheet_hud.png") @('Survival bars: full, low (warnings), the trek Nerve bar')
M '2' 'Mailbox and entrance' @("$R/F_sheet_mailbox.png", "$R/F_mailbox_frames.png") @('Entrance day/dusk/night; the mailbox flag up, checked, in snow', 'Clip: a letter arrives, the flag rises, the farmer checks it, the door opens')
M '3' 'Furniture' @("$R/C_furniture.png") @('Every replaced piece: old and new, native and 4x')
M '3b' 'Furniture in the house' @("$R/F_sheet_furniture.png") @('In the restored house: bedroom, desk at night (no red light), everything bought')
M '4' 'Layout and restoration' @("$R/F_sheet_stages.png", "$R/F_hearth_frames.png") @('The four stages at noon; restored and decrepit at 21:30', 'Clip: the restored house at night, the fire and every candle')
M '5' 'Clipping audit' @("$R/C_clipping.png", "$R/C_collision.png") @('What the audit found and how each was fixed', 'Each stage: solid pieces, interactions, walls, reachable floor')
M '6' 'Farmer design' @("$R/D_farmer_old_new.png", "$R/F_sheet_farmer.png", "$R/D_strips_move.png") @('Old vs new farmer', 'The farmer on the farm by day and night, indoors and in the cave', 'Idle and walk, every facing')
M '7' 'Lantern and tools' @("$R/F_walk_lantern_frames.png", "$R/F_lantern_belt_frames.png") @('Clip: walking at night, the lantern in hand and its light on it', 'Clip: hand to belt for the hoe and back')
M '7b' 'Tool animations' @("$R/D_strips_tools.png") @('Every tool animation (strips; unchanged since Phase D)')
M '8' 'Combat' @("$R/F_sheet_combat.png", "$R/F_combat_frames.png", "$R/F_block_frames.png", "$R/D_strips_attack.png") @('In the cave: striking, hurt, by lantern and daylight', 'Clip: the lizard strikes, a guarded blow, three hits and the fall', 'Clip: a guarded blow, then a landed one (flinch)', 'Attack strips for each weapon')
M '9' 'Cave creatures' @("$R/E_strips.png", "$R/F_combat_bat_frames.png") @('Every creature state and frame', 'Clip: the bat notices, dives, takes two hits and falls')
M '10' 'Debug menu' @("$R/F_sheet_debug.png", "$R/F_debug_frames.png") @('The panel; forced snow and 20 F with the overrides badge', 'Clip: force rain, then snow, jump to 21:30, clear all')
M '11' 'Final consistency' @("$R/F_sheet_consistency.png", "$R/F_window_snow_frames.png") @('Farm day and night, the cave, the restored house in winter and autumn', 'Clip: snow past the restored house windows')
M '11b' 'Seasons' @("$R/F_sheet_seasons.png") @('The four seasons at noon')
