# Builds the demo trailer. Each shot is a new game set up by tools/capture.gd (with hold= and walk=) and recorded by
# Godot's Movie Maker at 30 fps; ffmpeg then trims the warm-up, fades each shot, adds the title cards between them,
# and lays dreary_loop.ogg over the game's own sound. Everything lands in builds/trailer/ (gitignored).
#   & .\tools\trailer.ps1                      record every shot, then build demo_trailer.mp4 and sheet.png
#   & .\tools\trailer.ps1 -Only crows,cave     record just these shots again, then build
#   & .\tools\trailer.ps1 -Build               build from the shots already recorded
# sheet.png is one frame every two seconds of the trailer, for checking it in a single look.
param([string[]]$Only = @(), [switch]$Build)

$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot
$Godot = 'C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe'
$Work = Join-Path $Root 'builds/trailer'
$Font = 'C\:/Windows/Fonts/georgia.ttf'

function Find-Tool($name) {
	$cmd = Get-Command $name -ErrorAction SilentlyContinue
	if ($cmd) { return $cmd.Source }
	$found = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter "$name.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
	if (-not $found) { throw "$name not found (winget install Gyan.FFmpeg)" }
	return $found.FullName
}
$Ffmpeg = Find-Tool 'ffmpeg'

# The trailer in order: a shot (its capture.gd options) or a title card, and how long each stays on screen.
$Sequence = @(
	@{ shot = 'title';  secs = 4;   opts = 'title' }
	@{ card = 'The Rooks farmed here before you.'; secs = 2.5 }
	@{ shot = 'spring'; secs = 4;   opts = 'quiet season=Spring weather=sunny hour=8 crops=turnip,corn walk=right:3' }
	@{ shot = 'summer'; secs = 4;   opts = 'quiet season=Summer weather=sunny hour=13 built stage=3 walk=left:3.5' }
	@{ shot = 'walker'; secs = 4;   opts = 'quiet walker wedge weather=fog walk=up:1' }
	@{ shot = 'winter'; secs = 4;   opts = 'quiet season=Winter weather=snow hour=17 walk=down:3' }
	@{ card = 'Day is work.|Night is dread.'; secs = 3 }
	@{ shot = 'house';  secs = 3.5; opts = 'quiet inside stage=3 hour=22 lantern=2 walk=right:1.5' }
	@{ shot = 'crows';  secs = 4;   opts = 'quiet tile=55,27 hour=22 lantern=2 weather=cloudy'; gamma = 1.5 }
	@{ shot = 'figure'; secs = 4;   opts = 'hour=22 lantern=2 visitor=first beat=2'; gamma = 1.4 }
	@{ shot = 'sighting'; secs = 4; opts = 'tile=54,17 hour=22 lantern=2 visitor=sighting beat=1'; gamma = 1.4 }
	@{ card = 'She went after him, into the wood.'; secs = 2.5 }
	@{ shot = 'edge';   secs = 4;   opts = 'trek=1 troute=edge tday=4 tall walk=up:1' }
	@{ shot = 'fork';   secs = 4;   opts = 'trek=0 tsign tevent=fog walk=up:2' }
	@{ shot = 'tall';   secs = 4;   opts = 'trek=1 tdark tall tnight' }
	@{ shot = 'cave';   secs = 3;   opts = 'cave lantern=2 fight'; gamma = 1.4 }
	@{ shot = 'fish';   secs = 3;   opts = 'quiet fish season=Autumn hour=17' }
	@{ shot = 'diary';  secs = 3;   opts = 'quiet diary pages=10 tpages=2 dpage=1,0' }
	@{ card = 'Hang the bell again.'; secs = 2.5 }
	@{ card = 'CROW CREEK HOLLOW|Demo'; secs = 4; title = $true }
)

function Record-Shot($s) {
	$dir = Join-Path $Work "shots/$($s.shot)"
	New-Item -ItemType Directory -Force $dir | Out-Null
	Get-ChildItem $dir | Remove-Item -Force
	Write-Host "recording $($s.shot)"
	$gargs = @('--path', $Root, '--write-movie', "$dir/f.png", '--fixed-fps', '30', '-s', 'tools/capture.gd', '--', "hold=$($s.secs)") + ($s.opts -split ' ')
	# Godot prints harmless errors at exit; they mustn't stop the build.
	$ErrorActionPreference = 'Continue'
	& $Godot @gargs 2>&1 | Out-Null
	if ((Get-ChildItem $dir -Filter 'f*.png').Count -lt $s.secs * 30) { throw "shot $($s.shot) recorded too few frames" }
}

$Fade = 0.4
$enc = @('-c:v', 'libx264', '-tune', 'animation', '-crf', '16', '-pix_fmt', 'yuv420p', '-r', '30', '-c:a', 'aac', '-ar', '48000', '-ac', '2')

# A shot keeps its last secs of frames (the warm-up before it is cut), faded in and out from black.
function Clip-Shot($s, $out) {
	$dir = Join-Path $Work "shots/$($s.shot)"
	$n = (Get-ChildItem $dir -Filter 'f*.png').Count
	$keep = [int]($s.secs * 30)
	$start = [Math]::Max(0, $n - $keep)
	$ss = '{0:0.###}' -f ($start / 30)
	$fo = '{0:0.###}' -f ($s.secs - $Fade)
	# gamma lifts the darkest night shots a little, so they read on a bright screen.
	$lift = if ($s.gamma) { "eq=gamma=$($s.gamma)," } else { '' }
	& $Ffmpeg -y -v error -framerate 30 -start_number $start -i "$dir/f%08d.png" -ss $ss -i "$dir/f.wav" -t $s.secs `
		-vf "$($lift)fade=t=in:d=$($Fade):st=0,fade=t=out:st=$($fo):d=$Fade" -af "afade=t=in:d=$Fade,afade=t=out:st=$($fo):d=$Fade" @enc $out
}

# A card is pale serif text on black; "|" splits it into lines. The last card is the game's name, larger.
function Clip-Card($c, $i, $out) {
	$lines = $c.card -split '\|'
	$size = if ($c.title) { 64 } else { 40 }
	$gap = $size * 1.6
	$filters = @()
	for ($l = 0; $l -lt $lines.Count; $l++) {
		$txt = Join-Path $Work "card$($i)_$l.txt"
		[IO.File]::WriteAllText($txt, $lines[$l])
		$fs = if ($c.title -and $l -gt 0) { 28 } else { $size }
		$y = "(h/2)-($($gap * ($lines.Count - 1) / 2))+($($gap * $l))-(th/2)"
		$tp = ($txt -replace '\\', '/') -replace ':', '\:'
		$filters += "drawtext=fontfile='$Font':textfile='$tp':fontcolor=0xd9cfb4:fontsize=$($fs):x=(w-tw)/2:y=$y"
	}
	$fo = '{0:0.###}' -f ($c.secs - 0.6)
	$vf = ($filters -join ',') + ",fade=t=in:d=0.6:st=0,fade=t=out:st=$($fo):d=0.6"
	& $Ffmpeg -y -v error -f lavfi -i "color=c=black:s=1280x720:r=30:d=$($c.secs)" -f lavfi -i 'anullsrc=r=48000:cl=stereo' `
		-t $c.secs -vf $vf @enc $out
}

if (-not $Build) {
	foreach ($s in $Sequence) {
		if ($s.shot -and ($Only.Count -eq 0 -or $Only -contains $s.shot)) { Record-Shot $s }
	}
}

$clips = Join-Path $Work 'clips'
New-Item -ItemType Directory -Force $clips | Out-Null
$list = @()
$total = 0.0
for ($i = 0; $i -lt $Sequence.Count; $i++) {
	$s = $Sequence[$i]
	$out = Join-Path $clips ('{0:00}.mp4' -f $i)
	if ($s.shot) { Clip-Shot $s $out } else { Clip-Card $s $i $out }
	$list += "file '$($out -replace '\\', '/')'"
	$total += $s.secs
}
$listFile = Join-Path $Work 'clips.txt'
[IO.File]::WriteAllLines($listFile, $list)
$joined = Join-Path $Work 'joined.mp4'
& $Ffmpeg -y -v error -f concat -safe 0 -i $listFile -c copy $joined

# The music runs under the whole trailer, the game's sound over it, and both fade out over the last two seconds.
$fo = '{0:0.###}' -f ($total - 2)
$mix = "[1:a]volume=0.7,afade=t=in:d=1,afade=t=out:st=$($fo):d=2[m];[0:a]volume=1.2[g];[g][m]amix=inputs=2:duration=first:normalize=0[a]"
$final = Join-Path $Work 'demo_trailer.mp4'
& $Ffmpeg -y -v error -i $joined -stream_loop -1 -i (Join-Path $Root 'audio/dreary_loop.ogg') -filter_complex $mix `
	-map 0:v -map '[a]' -c:v copy -c:a aac -b:a 192k -movflags +faststart $final
& $Ffmpeg -y -v error -i $final -vf 'fps=1/2,scale=320:-1,tile=5x6' -frames:v 1 (Join-Path $Work 'sheet.png')
Write-Host ("built {0} ({1:0.#} s)" -f $final, $total)
