# CCH-CONSOLIDATED-003 Phase F: the final package's GIFs (and frame grids), recorded from the final build through
# tools/review_motion.ps1 (Movie Maker, 30 fps of game time). Run from the repository root:
#   & .\tools\cch003_motion_f.ps1            (all clips)   & .\tools\cch003_motion_f.ps1 -Only combat,debug
# The farmer's tool clips of Phase D (D_after_tool_*.gif) still show the final build: nothing that draws him has
# changed since db6aa73, so they are linked rather than re-recorded.
param([string[]] $Only = @())
$ErrorActionPreference = 'Stop'
$R = 'art/style_tests/CCH-003/review'
$clips = [ordered]@{
    # Walking the farm at night with the lantern in hand (tier 2): the light rides on it.
    'walk_lantern' = @{ o = 'tile=50,30 hour=21.5 weather=cloudy lantern=2 walk=right:1.2,down:0.9,left:1.2,up:0.9'; s = 4.4; c = '420:300' }
    # Hand to belt and back: walking with the lantern, then hoeing twice (it hangs on the belt), then walking on.
    'lantern_belt' = @{ o = 'tile=50,30 hour=21.5 weather=cloudy lantern=2 slot=3 walk=right:0.8,use:0.9,use:0.9,right:0.9'; s = 3.6; c = '360:260' }
    # Combat in the cave: the lizard notices and strikes, the farmer guards one blow, then three sword hits kill it.
    'combat' = @{ o = 'cave ctile=16,19 face=right weapon=iron_sword lantern=3 creatures=live ckinds=lizard chp=13 walk=wait:1.3,block:1.0,use:0.55,use:0.55,use:1.5'; s = 5.0; c = '400:200' }
    # The bat: alert, the dive, two hits and the fall.
    'combat_bat' = @{ o = 'cave ctile=16,19 face=right weapon=copper_sword lantern=3 creatures=live ckinds=bat chp=9 walk=wait:1.6,use:0.55,use:0.55,use:1.5'; s = 4.2; c = '400:200' }
    # Guarding a blow and taking one: the shield jolts, then the flinch.
    'block' = @{ o = 'tile=50,30 face=right hour=12 weather=sunny weapon=iron_sword walk=block+blow:1.2,wait:0.5,blow:1.2'; s = 2.9; c = '300:220' }
    # The mailbox: a letter arrives, the flag rises, the farmer checks it, the door opens, the flag drops.
    'mailbox' = @{ o = 'tile=53,33 face=up hour=12 weather=sunny mail=0 walk=wait:0.8,letter:1.4,hand:1.6'; s = 3.8; c = '360:260' }
    # The restored house at night: the fire and every candle flicker.
    'hearth' = @{ o = 'inside stage=3 hour=21.5 weather=cloudy fire=6 estate clock'; s = 3.0; c = '900:540' }
    # Winter snow past the restored house's windows, the fire lit.
    'window_snow' = @{ o = 'inside stage=3 season=Winter weather=snow hour=12 fire=6'; s = 3.0; c = '900:540' }
    # The developer panel: forcing rain, then snow, then jumping to 21:30 and clearing every override.
    'debug' = @{ o = 'debug hour=12 weather=sunny walk=wait:0.8,dw-rain:1.2,dw-snow:1.2,dh-21.5:1.2,dclear:1.0'; s = 5.4; c = '1280:720' }
}
foreach ($k in $clips.Keys) {
    if ($Only.Count -and -not ($Only -contains $k)) { continue }
    $c = $clips[$k]
    & "$PSScriptRoot\review_motion.ps1" -Out "$R/F_$k" -Opts $c.o -Secs $c.s -Crop $c.c -Frames 12 -Every ([int][math]::Floor($c.s * 30 / 12))
}
