# Combines a review package's contact sheets and motion frame grids into one master PNG, the file the owner
# attaches to ChatGPT (AI_COLLAB/VISUAL_REVIEW_PROTOCOL.md). A header says what it is: the task, the commit, what
# changed, what is in it and what it can't show. The sheets are laid out in the grid that shrinks them least, and
# the whole sheet is fitted within -MaxSide px on its long side, because ChatGPT shrinks bigger images before it
# looks at them. Text is drawn after the fit, so it stays readable.
#   & .\tools\review_master.ps1 -Out art/style_tests/VIS-001/review/VIS-001_master.png -Task VIS-001 `
#       -Commit abc1234 -Summary "What changed, and what to judge." `
#       -Sheets art/style_tests/VIS-001/review/farm.png, art/style_tests/VIS-001/review/lantern_frames.png `
#       -Captions "Farm: day, dusk, night, trek", "Hollow Lantern: 6 frames standing still"
# It prints the scale the sheets were drawn at. Below about 50% fine pixel detail is lost: say so in the review,
# and make a second master (…_master_2.png) for the rest rather than shrinking further.
param(
    [Parameter(Mandatory)] [string] $Out,
    [Parameter(Mandatory)] [string] $Task,
    [Parameter(Mandatory)] [string] $Summary,
    [Parameter(Mandatory)] [string[]] $Sheets,
    [string[]] $Captions = @(),
    [string] $Commit = '(not committed yet)',
    [string] $Motion = 'Motion is shown as frame grids; the GIFs are linked on the message board. Still frames cannot show timing or smoothness.',
    [int] $MaxSide = 2048
)
Add-Type -AssemblyName System.Drawing

function Load([string] $path) {
    $ms = New-Object IO.MemoryStream(, [IO.File]::ReadAllBytes((Resolve-Path $path)))
    [System.Drawing.Image]::FromStream($ms)
}

$imgs = @($Sheets | ForEach-Object { Load $_ })
$gap = 24
$capH = 30
$headerGuess = 260

# Try every column count and keep the one whose layout needs the least shrinking to fit.
$best = $null
for ($cols = 1; $cols -le $imgs.Count; $cols++) {
    $rows = [math]::Ceiling($imgs.Count / $cols)
    $colW = @(for ($c = 0; $c -lt $cols; $c++) {
        $m = 0
        for ($i = $c; $i -lt $imgs.Count; $i += $cols) { $m = [math]::Max($m, $imgs[$i].Width) }
        $m
    })
    $rowH = @(for ($r = 0; $r -lt $rows; $r++) { ($imgs[($r * $cols)..([math]::Min(($r + 1) * $cols, $imgs.Count) - 1)] | ForEach-Object { $_.Height } | Measure-Object -Maximum).Maximum + $capH })
    $w = ($colW | Measure-Object -Sum).Sum + $gap * ($cols + 1)
    $h = ($rowH | Measure-Object -Sum).Sum + $gap * ($rows + 1)
    $s = [math]::Min(1.0, $MaxSide / [math]::Max($w, $h + $headerGuess))
    if ($null -eq $best -or $s -gt $best.s) { $best = @{ cols = $cols; colW = $colW; rowH = $rowH; s = $s } }
}
$s = $best.s
$cols = $best.cols

# Lay out at the fitted scale. Captions and the header are drawn at full size on top, so they stay readable; if the
# finished sheet still overflows -MaxSide, shrink the sheets a little more and lay out again.
$titleFont = New-Object System.Drawing.Font 'Arial', 20, ([System.Drawing.FontStyle]::Bold)
$textFont = New-Object System.Drawing.Font 'Arial', 12
$capFont = New-Object System.Drawing.Font 'Arial', 13, ([System.Drawing.FontStyle]::Bold)
$probe = [System.Drawing.Graphics]::FromImage((New-Object System.Drawing.Bitmap 1, 1))
$contents = ($Sheets | ForEach-Object -Begin { $n = 0 } -Process { $n++; $cap = if ($Captions.Count -ge $n) { $Captions[$n - 1] } else { [IO.Path]::GetFileName($_) }; "$n. $cap  ($([IO.Path]::GetFileName($_)))" }) -join "`n"
for ($pass = 0; $pass -lt 8; $pass++) {
    $scaledW = @($best.colW | ForEach-Object { [int]($_ * $s) })
    $scaledRowH = @($best.rowH | ForEach-Object { [int](($_ - $capH) * $s) + $capH })
    $width = [math]::Max(($scaledW | Measure-Object -Sum).Sum + $gap * ($cols + 1), 900)
    $textW = $width - $gap * 2
    $lines = @(
        "Commit: $Commit    Date: $(Get-Date -Format 'yyyy-MM-dd')    Sheets drawn at $([math]::Round($s * 100))% of their size",
        $Summary,
        "Contents:`n$contents",
        $Motion,
        'Attach this file to ChatGPT for an image-level review. A review counts only once it is recorded on AI_COLLAB/MESSAGE_BOARD.md.'
    )
    $lineH = @($lines | ForEach-Object { [math]::Ceiling($probe.MeasureString($_, $textFont, $textW).Height) + 6 })
    $headerH = $gap + 34 + ($lineH | Measure-Object -Sum).Sum + 8
    $height = $headerH + ($scaledRowH | Measure-Object -Sum).Sum + $gap * ($best.rowH.Count + 1)
    if ([math]::Max($width, $height) -le $MaxSide) { break }
    $s *= 0.97 * $MaxSide / [math]::Max($width, $height)
}

$bmp = New-Object System.Drawing.Bitmap ([int]$width), ([int]$height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::FromArgb(28, 30, 27))
$g.TextRenderingHint = 'AntiAliasGridFit'
$white = [System.Drawing.Brushes]::White
$soft = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(210, 214, 205))
$g.DrawString("$Task  MASTER REVIEW SHEET", $titleFont, $white, $gap, $gap)
$y = $gap + 34
for ($i = 0; $i -lt $lines.Count; $i++) {
    $g.DrawString($lines[$i], $textFont, $soft, (New-Object System.Drawing.RectangleF $gap, $y, $textW, $lineH[$i]))
    $y += $lineH[$i]
}

# Shrinking pixel art needs smoothing to stay legible; at full size it stays crisp.
$g.InterpolationMode = if ($s -lt 1.0) { 'HighQualityBicubic' } else { 'NearestNeighbor' }
$g.PixelOffsetMode = 'Half'
$y = $headerH + $gap
for ($i = 0; $i -lt $imgs.Count; $i++) {
    $r = [math]::Floor($i / $cols)
    $c = $i % $cols
    if ($c -eq 0 -and $i -gt 0) { $y += $scaledRowH[$r - 1] + $gap }
    $x = $gap + (($scaledW | Select-Object -First $c) | Measure-Object -Sum).Sum + $gap * $c
    $cap = if ($Captions.Count -gt $i) { "$($i + 1). $($Captions[$i])" } else { "$($i + 1). $([IO.Path]::GetFileName($Sheets[$i]))" }
    $g.DrawString($cap, $capFont, $white, $x, $y)
    $g.DrawImage($imgs[$i], $x, $y + $capH, [int]($imgs[$i].Width * $s), [int]($imgs[$i].Height * $s))
    $imgs[$i].Dispose()
}

$dir = Split-Path -Parent $Out
if ($dir) {
    New-Item -ItemType Directory -Force $dir | Out-Null
    $ignore = Join-Path $dir '.gdignore'
    if (-not (Test-Path $ignore)) { New-Item -ItemType File $ignore | Out-Null }
}
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
"saved $Out ($width x $height, sheets at $([math]::Round($s * 100))%)"
if ($s -lt 0.5) { "warning: the sheets are below 50%; split them across two masters to keep pixel detail" }
