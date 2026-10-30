# Crow Creek Hollow: music brief

A brief for a composer, or for licensing existing music. It describes every piece of music the game needs, when each plays, and how to deliver it. The game already plays a synthesized stand-in for each track, so a delivered file drops straight in.

## The game

Crow Creek Hollow is a top-down pixel-art farming game with a horror story under it. You inherit a run-down farm at the edge of a dark wood in the Pacific Northwest. By day you plant, fish, forage, mend the house and sell at a roadside stand. At night, something stands at the edge of the field. Neighbours ask you to walk them through the Rookery Wood with your lantern while a tall figure moves in the trees. The pages of the farm's last owner, Agnes Rook, tell you what happened before you came, and in the second year the story reaches one of three endings.

**Tone.** Pacific Northwest autumn: wet cedar and fir, low cloud, woodsmoke, rain on a tin roof, crows. Folk horror rather than monster horror: the dread comes from the place, the old ways and what the neighbours won't say. Atmosphere over jump scares. The day should feel like a real comfort, so the nights cost something.

**Sound.** Lo-fi, worn and analog, as if played in a cold room and recorded to old tape: soft attacks, a little wow and flutter, tape hiss or room tone, rolled-off highs, nothing glossy or hyper-produced. Small, acoustic ensembles. Melodies are simple and singable, often modal (dorian, aeolian, mixolydian, phrygian). Space and silence are part of the score: the game deliberately drops the music at its most frightening moments, so the music never has to do the scaring alone.

**Palette for the whole score:** nylon or steel-string acoustic guitar, upright or felted piano, a slightly detuned old upright, pump organ or harmonium, fiddle, cello, wooden flute or low whistle, music box or celesta, hand bells, banjo (sparingly, summer), bowed metal and bowed saw, low drones, brushed or muffled kit, frame drum. Avoid: orchestral hits, trailer-style braams, EDM, choirs singing words, anything that sounds like a stock horror library.

**References, in words.** The quiet, wistful acoustic loops of cosy farming games; the slow, modal folk of the British folk revival and Appalachian ballads; the analog warmth of late-night lo-fi beats; the patient, textural dread of slow-burn folk horror films, where a held drone and a single out-of-tune note do more than a crescendo; the hiss and wobble of a cassette left in a car for a few summers.

## How the game uses music

A music director (`scripts/music_system.gd`) picks one track at a time from what is happening, highest priority first, and crossfades between them over about 3 seconds:

1. the title screen;
2. an ending playing;
3. a night visitor on the farm: its stinger, then the dread track (the Hollow gets its own pair);
4. a trek, with a tense layer faded in and out over it;
5. the mining cave;
6. **silence** on a "too quiet" night and when sanity is very low (the heartbeat and whispers take over);
7. in the farmhouse: a gentle track by day, **silence** after dark;
8. outdoors from 19:00: the night track;
9. outdoors by day: the season's theme.

Stingers (one-shots) play over the music for big moments, and the music ducks under them. An open menu lowers the music but doesn't stop it. Ambience (wind, rain, crickets, the house, the cave) plays under everything, so leave room for it: avoid sustained high hiss, constant rain sounds, or bird calls in the music itself.

Players will hear the day themes for hours. They must be easy to live with: no hooks that wear thin, no busy percussion, a gentle dynamic range, and an ending that flows back into the start.

## The tracks

Lengths are a guide; a loop must be a whole number of bars. **Priority** shows what to commission first if the budget is tight: the 10 "core" tracks are the essential set (6 is the bare minimum: title, autumn, night, trek, cave, hollow). Every loop starts at 0 and loops back to 0 at the end of its last bar (no intro/outro sections unless agreed: the game crossfades in and out).

| id | Priority | Plays | Mood | Length | Tempo | Key / mode (suggested) | Instruments (suggested) |
|---|---|---|---|---|---|---|---|
| `title` | Core | The title and slot menu | An old photograph of the farm; beautiful, sad, with something not right at the edge | 1:30-2:30 loop | 50-66 BPM | D minor | Music box or celesta, pump organ, distant bowed saw |
| `spring` | Core | Outdoors by day, March-May | Thaw, first green, cautious hope | 2:00-3:00 loop | 76-90 | G mixolydian | Fingerpicked guitar, wooden flute, light brushes |
| `summer` | Core | Outdoors by day, June-August | Warm, lazy, the long evenings; the safest the farm ever feels | 2:00-3:00 loop | 84-100 | C lydian or major | Banjo or guitar, felted piano, brushes, hand claps far off |
| `autumn` | Core | Outdoors by day, September-November (the game starts here) | Rain, woodsmoke, harvest; cosy with a chill under it | 2:00-3:00 loop | 66-80 | A dorian | Old upright or Rhodes, fiddle, muffled lo-fi kit, tape hiss |
| `winter` | Core | Outdoors by day, December-February | Cold, sparse, white; loneliness | 2:00-3:00 loop | 54-66 | E minor | Celesta or hand bells, soft pad, cello |
| `night` | Core | Outdoors from 19:00 | Watched from the trees; still and uneasy, never loud | 2:00-3:00 loop | 46-60, loose | B phrygian | Low drone, sparse low whistle or flute, bowed metal, long gaps |
| `trek` | Core | Walking a neighbour through the Rookery Wood | Careful steps, a lantern, keeping someone safe; a steady pulse | 1:30-2:30 loop | 72-88 | C# minor | Low guitar ostinato, cello drone, frame drum pulse |
| `trek_tense` | Core (stem) | Layered over `trek` when the walker's nerve is low or the tall one is near | Danger closing in, the walker about to break | **Exactly the length of `trek`**, same tempo and bars | same as `trek` | same key, dissonant | Fiddle or cello tremolo, col legno, heartbeat kick, rising harmonics |
| `cave` | Core | In the mining cave | Deep, enclosed, dripping, the mountain's weight | 2:00-3:00 loop | 44-56, loose | E-flat phrygian | Drone, bowed metal, sparse bell or kalimba drips, sub swells |
| `hollow` | Core | The Hollow at the door, or its first sighting | The thing under the great tree; awe and terror, ritual | 1:30-2:30 loop | 36-48 | F phrygian, clusters | Very low drone cluster, tolling bell, detuned organ, breath-like textures |
| `ending` | Core | An ending's closing lines and its credits | Grief and release; the farm goes on | 2:30-3:30 loop (plays under about 2 minutes of lines and credits) | 58-70 | D dorian, resolving to major | Piano, fiddle melody, warm organ; the title's theme returning |
| `hearth` | Extra | Inside the farmhouse by day | Shelter, the fire, a kettle; very quiet | 2:00-3:00 loop | 60-70 | F major | Felted piano or nylon guitar alone |
| `dread` | Extra | A night visitor on the farm, after its stinger | Something is out there and you must face it | 1:00-2:00 loop | 40-52 | B-flat phrygian, clusters | Cello drone, heartbeat, scraping strings |

### Stingers

One-shots, no loop. They play over the music, which ducks under them, so they can be fuller than the loops. Let each ring out naturally to silence.

| id | Plays | Mood | Length | Suggested |
|---|---|---|---|---|
| `sting_visitor` | A night visitor appears | A held breath, then a jolt (not a jump scare) | 2-3 s | Low boom, a dissonant string swell |
| `sting_hollow` | The Hollow appears | Something enormous waking | 3-5 s | Sub boom, tritone cluster, a single bell |
| `sting_page` | One of Agnes Rook's pages is found | Discovery, a little sadness | 2-3 s | Rising minor music-box figure |
| `sting_achievement` | An achievement is earned | Small, warm reward | 1-2 s | Short major music-box figure |
| `sting_bell` | The crow bell rings for the first time (an ending's turning point) | Triumph that sounds ancient and costly | 5-8 s | A real tolling bell, three strikes, with a low drone under |

## Delivery

- **Format:** OGG Vorbis, 44.1 kHz, quality 6 or better (about 192 kbps). Stereo for the score; mono is fine for stingers. Also deliver 24-bit WAV masters of everything.
- **File names:** exactly the ids above, e.g. `autumn.ogg`, `trek_tense.ogg`, `sting_bell.ogg`. They go in `audio/music/`.
- **Loudness:** loops at **-18 LUFS integrated**; stingers at **-16 LUFS integrated**; true peak at most **-1.5 dBTP**. Keep the loops' loudness range modest (about 6-10 LU): players set one music volume, and the game balances tracks against each other from these levels.
- **Seamless loops:** each loop's file is exactly its musical length, starting on the first downbeat and ending at the end of its last bar, with the tails of the last bar's notes **folded back onto the start** (so the loop point has no click, gap or cut reverb). No silence at either end, and no fade in or out. Please test each in a looping player before delivery.
- **Stems for the trek:** `trek.ogg` and `trek_tense.ogg` are played together, sample-locked, and the tense layer is faded in and out over the base. They must be the same length to the sample, the same tempo and bars, and work both together and with `trek` alone. The base must not need the layer to feel complete. Please also deliver the stems of `trek` (e.g. pulse, drone, melody) as WAV, in case the game later layers more by the walker's nerve.
- **Reverb and noise:** keep tape hiss and room tone low (well under the music) and constant across a loop, so the seam can't be heard.
- **Rights:** the developer needs a perpetual, worldwide licence to use the music in the game, its trailers and store pages, and on a soundtrack release, on all platforms. Please state any samples or libraries used and confirm they allow this.
- **Revisions:** deliver a short sketch (30-60 s) of `autumn`, `night` and `trek` first, so the sound of the score can be agreed before the rest.

## Testing in the game

Copy the files into `audio/music/`, then run `godot --path . --headless --import` once. A missing file falls back to the old placeholder loop (`audio/dreary_loop.ogg`), so tracks can be delivered one at a time. `tools/capture.gd` with the `sound` option prints which track is playing and how loud. The levels per track are in `TRACKS` in `scripts/music_system.gd`.
