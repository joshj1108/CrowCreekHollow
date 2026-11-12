# CCH-CONSOLIDATED-003 Phase F: frame-time benchmark

Measured 2026-11-12 on the owner's PC, 1280x720 window, vsync off, 300 frames after 60 warm-up frames, three runs per
scene alternating BEFORE and AFTER; the median of the three is given. BEFORE = `b1e8235` (the commit before Phase A)
and AFTER = `fd59768` (Phase E, the final game code; Phase F changes no game code), each in a clean worktree without
the owner's uncommitted sunset experiment. Harness: `tools/perf_f.gd` (capture.gd's `perf`, plus, in the cave, five
live creatures, two bats, a lizard and two snakes, chasing and striking while the farmer swings the iron sword every
0.4 s; the same five in both builds).

| Scene | Options | BEFORE mean / p95 ms | AFTER mean / p95 ms |
|---|---|---|---|
| Farm day | `hour=12 weather=sunny tile=40,26` | 2.90 / 4.07 | 2.95 / 4.01 |
| Farm night | `hour=21.5 weather=cloudy lantern=2 tile=40,26` | 3.09 / 4.29 | 3.42 / 5.40 |
| Restored house, night, all candles and the fire | `inside stage=3 hour=21.5 weather=cloudy fire=6 estate clock` | 4.17 / 5.21 | 4.00 / 5.19 |
| Restored house, day | `inside stage=3 hour=12 weather=sunny fire=6 estate clock` | 4.11 / 5.29 | 4.18 / 5.27 |
| Autumn rain | `season=Autumn weather=rain hour=12 tile=40,26` | 3.55 / 4.74 | 3.41 / 4.58 |
| Winter snow | `season=Winter weather=snow hour=12 tile=40,26` | 3.14 / 4.16 | 3.22 / 4.36 |
| Fog at night | `weather=fog hour=21.5 lantern=2 tile=40,26` | 3.33 / 4.84 | 3.53 / 4.63 |
| Cave combat, upgraded lantern, five creatures | `cave ctile=16,19 face=right lantern=3` (perf_f.gd) | 3.55 / 4.39 | 3.82 / 4.73 |

Every scene stays under 5.5 ms at the 95th percentile (a 60 fps frame is 16.7 ms). The differences are within the
run-to-run spread: farm night's three AFTER runs were 3.56, 3.17 and 3.42 ms against BEFORE's 2.99, 3.20 and 3.09;
cave combat's 3.82, 3.60 and 3.84 against 3.45, 4.01 and 3.55. capture.gd's `process_ms_mean` column
(Performance.TIME_PROCESS) is left out: it reads 15-38 ms, more than the whole frame, so it is not a per-frame time.
