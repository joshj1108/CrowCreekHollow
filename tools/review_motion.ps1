# Records a short clip of a scene for a visual review of motion (AI_COLLAB/VISUAL_REVIEW_PROTOCOL.md): flickering
# lights, a moving lantern, animation. Godot's Movie Maker records tools/capture.gd's hold= at a fixed 30 fps, then
# ffmpeg makes a looping GIF and a PNG grid (three across) of evenly spaced frames, both cropped around the screen centre.
#   & .\tools\review_motion.ps1 -Out art/style_tests/VIS-001/review/lantern_after `
#       -Opts "lantern=3 hour=22.5 walk=right:2,wait:2" -Secs 4
# Writes <Out>.gif and <Out>_frames.png. The raw frames go to builds/review/ (gitignored).
# Movie Maker runs the game clock at exactly 30 fps, but anything timed by the wall clock (Time.get_ticks_msec)
# runs at the machine's real speed, so its pace in the clip can differ from play; say so in the review.
param(
    [Parameter(Mandatory)] [string] $Out,
    [Parameter(Mandatory)] [string] $Opts,
    [double] $Secs = 4,
    [int] $Skip = 100,            # frames to drop at the start: capture.gd's 90 warm-up frames and a few more
    [string] $Crop = '320:240',   # w:h around the centre of the 1280x720 frame
    [int] $Fps = 15,              # the GIF's frame rate (the strip always uses the recorded 30 fps frames)
    [int] $Frames = 6,            # frames in the strip
    [int] $Every = 4              # take every Nth frame for the strip
)
$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot
$Godot = 'C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe'
$ffmpeg = (Get-Command ffmpeg -ErrorAction SilentlyContinue).Source
if (-not $ffmpeg) {
    $ffmpeg = (Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter 'ffmpeg.exe' -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
}
if (-not $ffmpeg) { throw 'ffmpeg not found (winget install Gyan.FFmpeg)' }

$name = Split-Path -Leaf $Out
$work = Join-Path $Root "builds/review/$name"
if (Test-Path $work) { Remove-Item -Recurse -Force $work }
New-Item -ItemType Directory -Force $work | Out-Null

$gargs = @('--path', $Root, '--write-movie', "$work/f.png", '--fixed-fps', '30', '-s', 'tools/capture.gd', '--', "hold=$Secs", 'quiet') + ($Opts -split ' ')
# Godot writes warnings to stderr, which Windows PowerShell would turn into a stopping error.
$ErrorActionPreference = 'Continue'
& $Godot @gargs 2>&1 | Out-Null
$ErrorActionPreference = 'Stop'
if (-not (Test-Path "$work/f$('{0:D8}' -f $Skip).png")) { throw "recorded too few frames in $work" }

$dir = Split-Path -Parent (Join-Path $Root $Out)
New-Item -ItemType Directory -Force $dir | Out-Null
$ignore = Join-Path $dir '.gdignore'
if (-not (Test-Path $ignore)) { New-Item -ItemType File $ignore | Out-Null }

$crop = "crop=${Crop}:(in_w-$($Crop.Split(':')[0]))/2:(in_h-$($Crop.Split(':')[1]))/2"
$in = @('-y', '-loglevel', 'error', '-framerate', '30', '-start_number', "$Skip", '-i', "$work/f%08d.png")
& $ffmpeg @in -vf "$crop,fps=$Fps,split[a][b];[a]palettegen=max_colors=128[p];[b][p]paletteuse=dither=none" -loop 0 "$Root/$Out.gif"
& $ffmpeg @in -vf "$crop,select='not(mod(n\,$Every))',tile=$([math]::Min($Frames, 3))x$([math]::Ceiling($Frames / 3)):padding=4:color=0x222421" -frames:v 1 "$Root/${Out}_frames.png"
"saved $Out.gif and ${Out}_frames.png"
