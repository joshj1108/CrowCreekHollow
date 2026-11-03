# ART-003 wider homestead: draws the live 64x40 farm grid and the proposed layout side by side, each with the real
# 1280x720 camera footprint (26.67 x 15 tiles) laid over it, and the proposed layout's landmark sprite extents.
#   & .\art\style_tests\ART-003\wide\draw_blueprint.ps1 -Out art/style_tests/ART-003/review/wide/blueprint_footprints.png
param([Parameter(Mandatory)] [string] $Out)
Add-Type -AssemblyName System.Drawing
$Here = $PSScriptRoot
$Root = Resolve-Path (Join-Path $Here '..\..\..\..')
$live = Get-Content (Join-Path $Root 'tools\farm_grid.txt')
$prop = Get-Content (Join-Path $Here 'blueprint_wide.txt')
$T = 14; $pad = 24; $gw = 64 * $T; $gh = 40 * $T
$VW = 1280 / 48; $VH = 720 / 48
$col = [System.Collections.Generic.Dictionary[string,string]]::new([StringComparer]::Ordinal)   # case matters: d/D, b/B, ...
foreach ($kv in @(@('.', '4b5a2a'), @('T', '1f3320'), @('O', '3a3f55'), @('H', '7a5a3a'), @('D', '3a2414'), @('R', 'a07850'), @('d', 'c0703a'), @('b', '5a6a30'), @('B', '6a4424'), @('r', '9a9a90'), @('W', '70a0c0'), @('c', 'a59a88'), @('P', 'b08a5a'), @('X', '3a2a1a'), @('g', 'e0b060'), @('S', '6a4428'), @('w', 'b89e70'), @('o', 'd87a30'), @('~', '3a6a8a'), @('k', '8a6a40'), @('L', 'ffd060'), @('G', '2a4a2a'), @('F', '8a7a44'), @('A', 'c0a060'), @('K', '707070'), @('C', '101010'), @('Y', 'd0c080'))) { $col[$kv[0]] = $kv[1] }
function C([string] $h, [int] $a = 255) { [System.Drawing.Color]::FromArgb($a, [Convert]::ToInt32($h.Substring(0, 2), 16), [Convert]::ToInt32($h.Substring(2, 2), 16), [Convert]::ToInt32($h.Substring(4, 2), 16)) }
$headH = 96; $tableH = 250
$W = $pad * 3 + $gw * 2; $H = $headH + 30 + $gh + $tableH
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear((C '1e201e')); $g.TextRenderingHint = 'AntiAlias'
$white = [System.Drawing.Brushes]::White
$grey = New-Object System.Drawing.SolidBrush (C 'c8c8be')
$fT = New-Object System.Drawing.Font 'Arial', 18, ([System.Drawing.FontStyle]::Bold)
$fH = New-Object System.Drawing.Font 'Arial', 13, ([System.Drawing.FontStyle]::Bold)
$fS = New-Object System.Drawing.Font 'Arial', 10
$fL = New-Object System.Drawing.Font 'Arial', 10, ([System.Drawing.FontStyle]::Bold)
$g.DrawString('ART-003 wider homestead: proposed layout and the real gameplay camera footprint', $fT, $white, $pad, 8)
$g.DrawString("Both panels use the live 64x40 inner farm grid (1 square = 1 tile; the live tree border lies outside it). Each solid box is ONE ordinary gameplay screen at 1280x720: 26.67 x 15 tiles, centred on the farmer (SCALE 3, 48 px per tile; 1920x1080 shows the same tiles, larger). Dashed boxes are landmark sprite extents (art, not collision). Concept 02 frames the whole homestead at once; no single gameplay screen can, as the red box shows. Non-production proposal: the live farm, layout, saves and camera are unchanged.", $fS, $grey, (New-Object System.Drawing.RectangleF $pad, 40, ($W - 2 * $pad), 52))

function Grid($rows, [int] $ox, [int] $oy) {
    for ($y = 0; $y -lt 40; $y++) { for ($x = 0; $x -lt 64; $x++) {
        $ch = [string] $rows[$y][$x]; $h = if ($col.ContainsKey($ch)) { $col[$ch] } else { '808080' }
        $b = New-Object System.Drawing.SolidBrush (C $h); $g.FillRectangle($b, $ox + $x * $T, $oy + $y * $T, $T, $T); $b.Dispose() } }
    $pen = New-Object System.Drawing.Pen (C '000000' 40)
    for ($x = 0; $x -le 64; $x += 4) { $g.DrawLine($pen, $ox + $x * $T, $oy, $ox + $x * $T, $oy + $gh) }
    for ($y = 0; $y -le 40; $y += 4) { $g.DrawLine($pen, $ox, $oy + $y * $T, $ox + $gw, $oy + $y * $T) }
    $pen.Dispose()
}
function Box([int] $ox, [int] $oy, [double] $x0, [double] $y0, [double] $w, [double] $h, [string] $hex, [string] $label, [bool] $dash, [float] $width = 3) {
    $pen = New-Object System.Drawing.Pen (C $hex), $width
    if ($dash) { $pen.DashStyle = 'Dash' }
    $g.DrawRectangle($pen, [float]($ox + $x0 * $T), [float]($oy + $y0 * $T), [float]($w * $T), [float]($h * $T)); $pen.Dispose()
    if ($label) {
        $sz = $g.MeasureString($label, $fL); $lx = [float]($ox + $x0 * $T + 3); $ly = [float]($oy + $y0 * $T + 3)
        $bg = New-Object System.Drawing.SolidBrush (C '000000' 170); $g.FillRectangle($bg, $lx - 1, $ly - 1, $sz.Width + 2, $sz.Height); $bg.Dispose()
        $br = New-Object System.Drawing.SolidBrush (C $hex); $g.DrawString($label, $fL, $br, $lx, $ly); $br.Dispose()
    }
}
function View([int] $ox, [int] $oy, [double] $cx, [double] $cy, [string] $hex, [string] $label) {
    Box $ox $oy ($cx - $VW / 2) ($cy - $VH / 2) $VW $VH $hex $label $false 3
    $br = New-Object System.Drawing.SolidBrush (C $hex); $g.FillEllipse($br, [float]($ox + $cx * $T - 5), [float]($oy + $cy * $T - 5), 10, 10); $br.Dispose()
}

$y0 = $headH + 30
$x1 = $pad; $x2 = $pad * 2 + $gw
$g.DrawString('Live farm today (tools/farm_grid.txt), one screen at the new-game spot', $fH, $white, $x1, $headH + 6)
$g.DrawString('Proposed wider prototype (wide/blueprint_wide.txt), five ordinary-play views', $fH, $white, $x2, $headH + 6)
Grid $live $x1 $y0
Grid $prop $x2 $y0
# Live panel: one screen at the new-game spot, and the ART-003 slice laid over it.
Box $x1 $y0 17.5 11 30 18 'e0e0e0' 'ART-003 slice, 30x18 tiles' $true 2
View $x1 $y0 32.5 20.5 'ffd84a' 'One 1280x720 screen'
# Proposed panel: sprite extents, the whole homestead, then the five views.
Box $x2 $y0 3 1 58 36 'ff5a4a' '' $true 2
Box $x2 $y0 3 34.6 0.01 0.01 'ff5a4a' 'Concept 02 frames all of this (red) at once: 58 x 36 tiles = 5.2 screens' $false 1
Box $x2 $y0 39.5 1 12 10 'f0e8d0' '' $true 1.5
Box $x2 $y0 24.5 2 12 12 'f0e8d0' '' $true 1.5
$views = @(@(37.5, 9.5, 'ffd84a', 'V1 core: oak + house + well'), @(49, 24, '5ad0ff', 'V2 garden'), @(31, 19, 'ff7ad0', 'V3 arrival'), @(14, 27.5, 'a0ff70', 'V4 orchard + pond'), @(45, 12.5, 'ffa040', 'V5 porch'))
foreach ($v in $views) { View $x2 $y0 $v[0] $v[1] $v[2] $v[3] }

# Legend and the visibility table under the panels.
$ly = $y0 + $gh + 14
$items = @(@('T', 'forest'), @('O', 'roof'), @('H', 'house wall'), @('d', 'house dressing'), @('B', 'oak base'), @('r', 'boulders'), @('W', 'well'), @('c', 'cobbles'), @('P', 'path'), @('X', 'fence'), @('g', 'gate'), @('S', 'bed / soil'), @('w', 'walkway'), @('o', 'orchard tree'), @('~', 'water'), @('k', 'dock'), @('L', 'lamp (earned)'), @('G', 'grove tree'), @('F', 'fallow'), @('A', 'stall'), @('K', 'rock'))
$lx = $pad
foreach ($it in $items) {
    $b = New-Object System.Drawing.SolidBrush (C $col[$it[0]]); $g.FillRectangle($b, $lx, $ly + 2, 12, 12); $b.Dispose()
    $g.DrawString($it[1], $fS, $grey, $lx + 15, $ly); $lx += 15 + [int]$g.MeasureString($it[1], $fS).Width + 12
    if ($lx -gt $W - 140) { $lx = $pad; $ly += 18 }
}
$ly += 26
$table = Get-Content (Join-Path $Here 'footprints.md') | Where-Object { $_ -match '^\|' -and $_ -notmatch '---' }
$g.DrawString('Share of each landmark''s sprite that one screen shows (measured from the layout, not a capture):', $fH, $white, $pad, $ly); $ly += 22
$cw = @(330, 120, 120, 80, 120, 120, 120)
foreach ($row in $table) {
    $cells = $row.Trim('|').Split('|') | ForEach-Object { $_.Trim() }
    $cx = $pad
    for ($i = 0; $i -lt $cells.Count; $i++) { $g.DrawString($cells[$i], $fS, $grey, $cx, $ly); $cx += $cw[[math]::Min($i, $cw.Count - 1)] }
    $ly += 17
}
$note = (Get-Content (Join-Path $Here 'footprints.md') | Where-Object { $_ -match '^All|^Oak' }) -join '  '
$g.DrawString($note, $fS, $white, $pad, $ly + 4)
$g.Dispose()
$full = Join-Path $Root $Out
New-Item -ItemType Directory -Force (Split-Path $full) | Out-Null
$gi = Join-Path (Split-Path $full) '.gdignore'; if (-not (Test-Path $gi)) { New-Item -ItemType File $gi | Out-Null }
$bmp.Save($full); $bmp.Dispose()
"saved $Out ($W x $H)"
