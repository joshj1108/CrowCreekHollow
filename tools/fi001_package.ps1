# FARMHOUSE-INTERIOR-001: builds the review package (AI_COLLAB/VISUAL_REVIEW_PROTOCOL.md) from the captures made by
# tools/fi001_shots.sh (builds/review/fi001/A = this tree, B = the previous commit with the owner's uncommitted
# main.gd and shader), the motion clips (review_motion.ps1) and tools/fi001_review.py's art sheet and collision maps.
#   & .\tools\fi001_package.ps1 [-Commit SHA] [-SkipMotion]
param([string] $Commit = '(not committed yet)', [switch] $SkipMotion)
$ErrorActionPreference = 'Stop'
$T = 'FARMHOUSE-INTERIOR-001'
$A = 'builds/review/fi001/A'
$B = 'builds/review/fi001/B'
$C = 'builds/review/fi001/crops'
$R = "art/style_tests/$T/review"
New-Item -ItemType Directory -Force $C, $R | Out-Null
function Crop($src, $box, $scale, $out) { python tools/fi001_review.py crop $src $box $scale $out }

# Native-pixel crops, enlarged 2x (from full-size captures).
$hearth = '590,110,250,210'
$win = '520,108,150,130'
foreach ($k in 'f_unlit', 'f_lit', 'f_derelict_fire', 'f_low', 'f_night_all_full') { Crop "$A/$k.png" $hearth 2 "$C/$k`_hearth.png" }
Crop "$A/f_night_all_full.png" '150,170,260,150' 2 "$C/candles_bedroom.png"
Crop "$A/f_night_all_full.png" '400,150,240,260' 2 "$C/candles_hall.png"
foreach ($k in 'w_spring', 'w_summer', 'w_autumn', 'w_rain', 'w_winter', 'w_fog', 'w_night', 'w_shutters', 'w_s0', 'w_s1', 'w_dawn_shut', 'w_dawn_open') {
    Crop "$A/$k.png" $win 2 "$C/$k.png"
}
python tools/fi001_review.py art "$C/art_sheet.png"
python tools/fi001_review.py grid builds/review/fi001/grid.json $C

$sheet = '.\tools\review_sheet.ps1'
& $sheet -Out "$R/sheet2_layout.png" -Title "$T Sheet 2: layout, before and after" -Before 'BEFORE (HEAD f41666a)' -After 'AFTER' `
    -Change 'The farmhouse interior redesigned: rooms side by side under the north wall (bedroom, hall with the stone hearth, wash room over study), windows in every room, new floors, walls, hearth, props and lights, drawn for each repair stage. BEFORE stands in the old hall, AFTER at the new layout''s top camera; same options otherwise.' -Rows @(
    @{ Label = 'Decrepit (stage 0), 12:00 sunny, furniture bought as allowed'; Before = "$B/r_day_s0.png"; After = "$A/r_day_s0.png" },
    @{ Label = 'Boarded (stage 1), 12:00 sunny'; Before = "$B/r_day_s1.png"; After = "$A/r_day_s1.png" },
    @{ Label = 'Patched (stage 2), 12:00 sunny, fire lit'; Before = "$B/r_day_s2.png"; After = "$A/r_day_s2.png" },
    @{ Label = 'Restored (stage 3), 12:00 sunny, fire lit, every piece of furniture'; Before = "$B/r_day_s3.png"; After = "$A/r_day_s3.png" },
    @{ Label = 'Restored, 21:30, fire lit (night interior)'; Before = "$B/r_night_s3.png"; After = "$A/r_night_s3.png" },
    @{ Label = 'Navigation: standing on the entry mat (camera scrolled down: door, front windows, study)'; Before = "$B/nav_entry.png"; After = "$A/nav_entry.png" })

& $sheet -Out "$R/sheet_restoration.png" -Title "$T Restoration comparison: the same camera, every stage" -Before 'EARLIER STAGE' -After 'LATER STAGE' `
    -Change 'One camera position (standing at hall tile 12,5), the same options; only the house stage changes. Furniture is bought as each stage allows it, so it appears as it would in play.' -Rows @(
    @{ Label = 'Day 12:00: Decrepit (0) | Boarded (1)'; Before = "$A/r_day_s0.png"; After = "$A/r_day_s1.png" },
    @{ Label = 'Day 12:00: Patched (2) | Restored (3), fire lit'; Before = "$A/r_day_s2.png"; After = "$A/r_day_s3.png" },
    @{ Label = 'Night 21:30: Decrepit (0) | Boarded (1), no fire'; Before = "$A/r_night_s0.png"; After = "$A/r_night_s1.png" },
    @{ Label = 'Night 21:30: Patched (2) | Restored (3), fire lit'; Before = "$A/r_night_s2.png"; After = "$A/r_night_s3.png" })

& $sheet -Out "$R/sheet3_fire_light.png" -Title "$T Sheet 3: hearth and lighting" -Before 'LEFT' -After 'RIGHT' `
    -Change 'Hearth crops are native game pixels enlarged 2x. Firelight is one PointLight2D, on only while the fire burns; each lit candle has its own small PointLight2D.' -Rows @(
    @{ Label = 'Restored hearth, 12:00: cold (no light) | burning (2x crops)'; Before = "$C/f_unlit_hearth.png"; After = "$C/f_lit_hearth.png" },
    @{ Label = 'A fire in the Decrepit hearth, 21:30 | a low fire (0.5 h of fuel), Patched, 21:30'; Before = "$C/f_derelict_fire_hearth.png"; After = "$C/f_low_hearth.png" },
    @{ Label = 'Restored, 21:30: candles only, hearth cold | candles and the fire together'; Before = "$A/f_night_candles.png"; After = "$A/f_night_all.png" },
    @{ Label = 'Candles at 21:30, 2x crops: bedside table | the hall (table, mantel, clock)'; Before = "$C/candles_bedroom.png"; After = "$C/candles_hall.png" })

& $sheet -Out "$R/sheet4_windows.png" -Title "$T Sheet 4: windows, seasons and weather" -Before 'LEFT' -After 'RIGHT' `
    -Change 'The hall window (2x native crops). Glazed from Patched: open with the curtains stirring on mild dry days spring to autumn; shut in rain, fog, at night and in winter (misted, frosted edges); barred shutters show through the glass. Decrepit is boarded with cracked panes, Boarded has one board and an oilcloth pane.' -Rows @(
    @{ Label = 'Spring 12:00 sunny (open) | Summer 12:00 sunny (open)'; Before = "$C/w_spring.png"; After = "$C/w_summer.png" },
    @{ Label = 'Autumn 12:00 sunny (open) | Summer 15:00 rain (shut, rain on the glass)'; Before = "$C/w_autumn.png"; After = "$C/w_rain.png" },
    @{ Label = 'Winter 12:00 snow (shut, misted, frost) | Autumn 12:00 fog (shut, fog beyond)'; Before = "$C/w_winter.png"; After = "$C/w_fog.png" },
    @{ Label = 'Summer 21:30 (shut for the night) | the shutters barred'; Before = "$C/w_night.png"; After = "$C/w_shutters.png" },
    @{ Label = 'Decrepit, summer noon (boarded) | Boarded (one board, oilcloth pane)'; Before = "$C/w_s0.png"; After = "$C/w_s1.png" },
    @{ Label = 'State change, summer: 06:54 still shut | 07:12 opened'; Before = "$C/w_dawn_shut.png"; After = "$C/w_dawn_open.png" })

& $sheet -Out "$R/sheet6_world.png" -Title "$T Sheet 6: world integration" -Before 'BEFORE (HEAD f41666a)' -After 'AFTER' `
    -Change 'The farm outside is unchanged (outdoor lighting untouched); inside, the farmer at the entry, at the bed and at the hearth; a Boarded house at dusk.' -Rows @(
    @{ Label = 'Outside the house, 17:00 (no change expected)'; Before = "$B/x_outside.png"; After = "$A/x_outside.png" },
    @{ Label = 'Stepping inside, 17:00, Restored, fire lit'; Before = "$B/x_inside.png"; After = "$A/x_inside.png" },
    @{ Label = 'At the bed, 21:30'; Before = "$B/x_bed.png"; After = "$A/x_bed.png" },
    @{ Label = 'At the hearth, 21:30'; Before = "$B/x_hearth.png"; After = "$A/x_hearth.png" },
    @{ Label = 'Boarded house at dusk, 19:30 overcast'; Before = "$B/x_s1_dusk.png"; After = "$A/x_s1_dusk.png" })

& $sheet -Out "$R/sheet7_art_tech.png" -Title "$T Sheet 7: art and technical validation" -Before 'SPRITES' -After 'COLLISION' `
    -Change 'Left: every new interior sprite at 3x with its native size (scripted: floors, walls, windows, fire, cobwebs, rug; PixelLab: hearth and props). Right: each stage''s tiles with every piece of furniture bought, from tools/interior_test.gd (all open floor reachable from the door, shut rooms unreachable, every fixture faceable).' -Rows @(
    @{ Label = 'art/farm/fi/ | collision and interaction maps, stages 0-3'; Before = "$C/art_sheet.png"; After = "$C/collision_all.png" })

if (-not $SkipMotion) {
    $motion = '.\tools\review_motion.ps1'
    & $motion -Out "$R/motion_hearth_night" -Opts 'inside stage=3 estate fire=6 hour=21.5 weather=sunny itile=12,5' -Secs 4 -Crop '460:520'
    & $motion -Out "$R/motion_breeze" -Opts 'inside stage=3 estate hour=12 weather=sunny season=Summer itile=12,5' -Secs 4 -Crop '460:520'
    & $motion -Out "$R/motion_rain_glass" -Opts 'inside stage=3 hour=15 weather=rain season=Summer itile=12,5' -Secs 4 -Crop '460:520'
    & $motion -Out "$R/motion_draft_decrepit" -Opts 'inside stage=0 hour=15 weather=rain itile=12,5' -Secs 4 -Crop '460:520'
}

# Masters (absolute -Out: GDI+ saves relative to .NET's current directory, not PowerShell's). Sheets 6 and 7 go on
# masters of their own, since together they fell under 50%.
[Environment]::CurrentDirectory = (Get-Location).Path
$RA = (Resolve-Path $R).Path
$sum = 'The farmhouse interior rebuilt as a restoration story: rooms side by side under the north wall (bedroom, hall with a stone hearth, wash room over study), a window in every room, new floors, walls, hearth and props drawn for each repair stage (Decrepit, Boarded, Patched, Restored), a real flickering firelight only while the fire burns, a light for each lit candle, windows that open, shut, run with rain or frost by season and weather, and the clock pendulum. Judge: does it read as a warm, lived-in home being brought back to life; is stage 0 abandoned but readable; does the art match the house and farm.'
$cant = 'Still images cannot show the flicker, curtain sway, rain on the glass or pendulum timing; the GIFs on the board do (Movie Maker records at 30 fps of game time; the effects are timed by game frames, so their pace matches play).'
$master = '.	oolseview_master.ps1'
& $master -Out "$RA\${T}_master.png" -Task $T -Commit $Commit -Summary $sum -Motion $cant -Sheets "$R/sheet_restoration.png", "$R/sheet2_layout.png" -Captions 'Restoration comparison: the same camera at every stage, day and night', 'Sheet 2: layout before and after, stages 0-3, night, navigation'
& $master -Out "$RA\${T}_master_2.png" -Task $T -Commit $Commit -Summary $sum -Motion $cant -Sheets "$R/sheet3_fire_light.png", "$R/sheet4_windows.png" -Captions 'Sheet 3: hearth and lighting (2x native crops)', 'Sheet 4: windows, seasons and weather (2x native crops)'
& $master -Out "$RA\${T}_master_3.png" -Task $T -Commit $Commit -Summary $sum -Motion $cant -Sheets "$R/motion_hearth_night_frames.png", "$R/motion_breeze_frames.png", "$R/motion_rain_glass_frames.png", "$R/motion_draft_decrepit_frames.png" -Captions 'Sheet 5a: hearth at night (fire, embers, sparks, candles, pendulum)', 'Sheet 5b: summer noon, window open, curtains in the breeze', 'Sheet 5c: rain on the glass, curtains still', 'Sheet 5d: Decrepit in rain, the rag curtain in the draft'
& $master -Out "$RA\${T}_master_4.png" -Task $T -Commit $Commit -Summary $sum -Motion $cant -Sheets "$R/sheet6_world.png" -Captions 'Sheet 6: world integration (outside unchanged; entry, bed, hearth, Boarded at dusk)'
& $master -Out "$RA\${T}_master_5.png" -Task $T -Commit $Commit -Summary $sum -Motion $cant -Sheets "$R/sheet7_art_tech.png" -Captions 'Sheet 7: new sprites at 3x and collision/interaction maps'
Write-Host 'package done'
