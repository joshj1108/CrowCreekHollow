# Part of the visual review tools (AI_COLLAB/VISUAL_REVIEW_PROTOCOL.md): a contact sheet for three-way comparisons.
# Labelled sheet with one column per tag (three for concept | Round 1 | Round 2; ART-003 Round 3 uses four). Each cell is scaled to fit
# CellW x CellH: crisp for game renders, smooth for the concept (no pixel grid).
param([string] $Out, [string] $Title, [string] $Note, [string[]] $Tags, [object[]] $Rows, [int] $CellW, [int] $CellH)
Add-Type -AssemblyName System.Drawing
function Load([string] $p) { $ms = New-Object IO.MemoryStream(, [IO.File]::ReadAllBytes($p)); [System.Drawing.Bitmap]::FromStream($ms) }
$pad = 14; $capH = 22; $tagH = 20
$titleF = New-Object System.Drawing.Font 'Arial', 18, ([System.Drawing.FontStyle]::Bold)
$textF = New-Object System.Drawing.Font 'Arial', 11
$capF = New-Object System.Drawing.Font 'Arial', 12, ([System.Drawing.FontStyle]::Bold)
$n = $Tags.Count
$W = $pad + $n * ($CellW + $pad)
$probe = [System.Drawing.Graphics]::FromImage((New-Object System.Drawing.Bitmap 1, 1))
$noteH = [math]::Ceiling($probe.MeasureString($Note, $textF, $W - 2 * $pad).Height)
$headH = 40 + $noteH + 10
$H = $headH + $Rows.Count * ($capH + $tagH + $CellH + $pad)
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::FromArgb(30, 32, 30))
$white = [System.Drawing.Brushes]::White; $grey = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(200, 200, 190))
$g.DrawString($Title, $titleF, $white, $pad, 8)
$g.DrawString($Note, $textF, $grey, (New-Object System.Drawing.RectangleF $pad, 38, ($W - 2 * $pad), $noteH))
$y = $headH
foreach ($row in $Rows) {
    $g.DrawString($row.Label, $capF, $white, $pad, $y + 2)
    $y += $capH
    $tg = if ($row.Tags) { $row.Tags } else { $Tags }
    for ($i = 0; $i -lt $n; $i++) {
        $x = $pad + $i * ($CellW + $pad)
        $g.FillRectangle([System.Drawing.Brushes]::Black, $x, $y, [math]::Min(220, $CellW), $tagH)
        $g.DrawString($tg[$i], $capF, $white, $x + 4, $y + 2)
        $img = Load $row.Files[$i]
        $k = [math]::Min($CellW / $img.Width, $CellH / $img.Height)
        $g.InterpolationMode = if ($row.Smooth -contains $i) { 'HighQualityBicubic' } else { 'NearestNeighbor' }
        $g.PixelOffsetMode = 'Half'
        $g.DrawImage($img, (New-Object System.Drawing.Rectangle $x, ($y + $tagH), ([int]($img.Width * $k)), ([int]($img.Height * $k))))
        $img.Dispose()
    }
    $y += $tagH + $CellH + $pad
}
$g.Dispose()
New-Item -ItemType Directory -Force (Split-Path $Out) | Out-Null
$gi = Join-Path (Split-Path $Out) '.gdignore'; if (-not (Test-Path $gi)) { New-Item -ItemType File $gi | Out-Null }
$bmp.Save($Out); $bmp.Dispose()
"saved $Out ($W x $H)"
