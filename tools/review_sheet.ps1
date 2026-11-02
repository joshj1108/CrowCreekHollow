# Builds a labelled BEFORE / AFTER contact sheet for a visual review (AI_COLLAB/VISUAL_REVIEW_PROTOCOL.md): a header
# with the task, the change and the commit, then one row per scene with its caption (scene, time, settings) and the
# two images side by side, each tagged BEFORE or AFTER. Images are drawn at their own size with crisp pixels.
#   & .\tools\review_sheet.ps1 -Out art/style_tests/VIS-001/review/farm.png -Title "VIS-001: farm lighting" `
#       -Change "What changed, in a sentence or two." -Rows @(
#         @{ Label = "Farm, 12:05, overcast, house stage 3"; Before = "x_before.png"; After = "x_after.png" })
# The folder gets a .gdignore, so Godot never imports or exports review images.
param(
    [Parameter(Mandatory)] [string] $Out,
    [Parameter(Mandatory)] [string] $Title,
    [Parameter(Mandatory)] [string] $Change,
    [Parameter(Mandatory)] [object[]] $Rows,
    [string] $Before = 'BEFORE',
    [string] $After = 'AFTER',
    [string] $Note = ''
)
Add-Type -AssemblyName System.Drawing

# Load through a memory copy so the files aren't locked.
function Load([string] $path) {
    $ms = New-Object IO.MemoryStream(, [IO.File]::ReadAllBytes((Resolve-Path $path)))
    [System.Drawing.Image]::FromStream($ms)
}

$pad = 16
$gap = 12
$pairs = @($Rows | ForEach-Object { , @((Load $_.Before), (Load $_.After)) })
$imgW = ($pairs | ForEach-Object { $_[0].Width, $_[1].Width } | Measure-Object -Maximum).Maximum
$width = $pad * 2 + $imgW * 2 + $gap

$titleFont = New-Object System.Drawing.Font 'Arial', 18, ([System.Drawing.FontStyle]::Bold)
$textFont = New-Object System.Drawing.Font 'Arial', 11
$labelFont = New-Object System.Drawing.Font 'Arial', 12, ([System.Drawing.FontStyle]::Bold)
$tagFont = New-Object System.Drawing.Font 'Arial', 12, ([System.Drawing.FontStyle]::Bold)

# Measure the wrapped header text on a scratch surface first, so the sheet is exactly tall enough.
$probe = [System.Drawing.Graphics]::FromImage((New-Object System.Drawing.Bitmap 1, 1))
$textW = $width - $pad * 2
$changeH = [math]::Ceiling($probe.MeasureString($Change, $textFont, $textW).Height)
$noteH = if ($Note) { [math]::Ceiling($probe.MeasureString($Note, $textFont, $textW).Height) + 6 } else { 0 }
$headerH = $pad + 30 + $changeH + $noteH + $pad
$rowH = @($pairs | ForEach-Object { [math]::Max($_[0].Height, $_[1].Height) + 28 + $gap })
$height = $headerH + ($rowH | Measure-Object -Sum).Sum + $pad

$bmp = New-Object System.Drawing.Bitmap ([int]$width), ([int]$height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::FromArgb(34, 36, 33))
$g.InterpolationMode = 'NearestNeighbor'
$g.PixelOffsetMode = 'Half'
$g.TextRenderingHint = 'AntiAliasGridFit'
$white = [System.Drawing.Brushes]::White
$soft = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(205, 210, 200))
$tagBack = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(200, 0, 0, 0))

$g.DrawString($Title, $titleFont, $white, $pad, $pad)
$g.DrawString($Change, $textFont, $soft, (New-Object System.Drawing.RectangleF $pad, ($pad + 30), $textW, $changeH))
if ($Note) {
    $g.DrawString($Note, $textFont, $soft, (New-Object System.Drawing.RectangleF $pad, ($pad + 36 + $changeH), $textW, $noteH))
}

$y = $headerH
for ($i = 0; $i -lt $pairs.Count; $i++) {
    $g.DrawString([string]$Rows[$i].Label, $labelFont, $white, $pad, $y)
    $iy = $y + 24
    for ($k = 0; $k -lt 2; $k++) {
        $img = $pairs[$i][$k]
        $x = $pad + $k * ($imgW + $gap)
        $g.DrawImage($img, $x, $iy, $img.Width, $img.Height)
        $tag = @($Before, $After)[$k]
        $tw = $g.MeasureString($tag, $tagFont).Width + 10
        $g.FillRectangle($tagBack, $x, $iy, $tw, 22)
        $g.DrawString($tag, $tagFont, $white, $x + 5, $iy + 3)
        $img.Dispose()
    }
    $y += $rowH[$i]
}

$dir = Split-Path -Parent $Out
if ($dir) {
    New-Item -ItemType Directory -Force $dir | Out-Null
    $ignore = Join-Path $dir '.gdignore'
    if (-not (Test-Path $ignore)) { New-Item -ItemType File $ignore | Out-Null }
}
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
"saved $Out"
