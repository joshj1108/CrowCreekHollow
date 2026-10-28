# Lays sprites out on one labelled preview image, scaled up with crisp pixels, for comparing
# SpriteCook variations in a single look.
#   & .\tools\sheet.ps1 -Out art/style_tests/x/sheet.png -Scale 4 -Files a.png, b.png
param(
    [Parameter(Mandatory)] [string] $Out,
    [Parameter(Mandatory)] [string[]] $Files,
    [int] $Scale = 4,
    [int] $Columns = 2
)
Add-Type -AssemblyName System.Drawing

# Load through a memory copy so the files aren't locked.
function Load([string] $path) {
    $ms = New-Object IO.MemoryStream(, [IO.File]::ReadAllBytes((Resolve-Path $path)))
    [System.Drawing.Image]::FromStream($ms)
}

$images = @($Files | ForEach-Object { Load $_ })
$cellW = ($images | ForEach-Object { $_.Width } | Measure-Object -Maximum).Maximum * $Scale + 20
$cellH = ($images | ForEach-Object { $_.Height } | Measure-Object -Maximum).Maximum * $Scale + 30
$rows = [math]::Ceiling($images.Count / $Columns)
$bmp = New-Object System.Drawing.Bitmap ([int]($cellW * [math]::Min($Columns, $images.Count))), ([int]($cellH * $rows))
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.Clear([System.Drawing.Color]::FromArgb(58, 64, 56))
$g.InterpolationMode = 'NearestNeighbor'
$g.PixelOffsetMode = 'Half'
$font = New-Object System.Drawing.Font "Arial", 11
for ($i = 0; $i -lt $images.Count; $i++) {
    $x = ($i % $Columns) * $cellW + 10
    $y = [math]::Floor($i / $Columns) * $cellH + 4
    $g.DrawString([IO.Path]::GetFileNameWithoutExtension($Files[$i]), $font, [System.Drawing.Brushes]::White, $x, $y)
    $g.DrawImage($images[$i], $x, $y + 22, $images[$i].Width * $Scale, $images[$i].Height * $Scale)
    $images[$i].Dispose()
}
$bmp.Save($Out)
"saved $Out"
