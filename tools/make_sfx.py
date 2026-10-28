"""Renders the farm's sound effects to audio/sfx/*.ogg.

Everything is synthesized here, so the sounds are original and reproducible. Run from the project folder with:
python tools/make_sfx.py   (needs numpy and soundfile: pip install numpy soundfile).

The sounds are built from filtered noise, wood and metal partials, plucked strings and formant voices, then given a
short room or outdoor reverb. Each sound is levelled to the loudness the game was balanced around (LOUDNESS below).
"""
import os
import zlib

import numpy as np
import soundfile as sf

SR = 44100
OUT_DIR = os.path.join("audio", "sfx")
RNG = np.random.default_rng(0)  # reseeded per sound, so changing one sound leaves the others the same

# Loudest 50 ms of each sound, in dBFS. These match the first set of sounds, which the game's volumes were tuned to.
LOUDNESS = {
    "step": -15.0, "plant": -11.6, "harvest": -10.3, "water": -14.6, "eat": -17.0, "drink": -9.4, "repair": -12.1,
    "coin": -13.4, "panel": -15.3, "tick": -21.3, "chime": -12.7, "bleat": -9.2, "buzz": -9.4, "thunder": -6.3,
    "door": -8.9, "strike": -15.3, "gather": -19.9,
    # The night, house and cave sounds are mostly played by the ambience, which sets their volume as it plays them.
    "crow": -11.0, "crow_far": -13.0, "owl": -12.0, "howl": -12.0, "snap_far": -12.0, "steps_behind": -14.0,
    "whisper": -14.0, "heartbeat": -10.0, "sting": -10.0, "knock": -9.0, "hen": -12.0,
    "creak": -12.0, "creak_high": -13.0, "settle": -11.0, "thunder_in": -8.0,
    "drip": -14.0, "drip_low": -14.0, "cave_rumble": -10.0, "skitter": -14.0, "cave_moan": -12.0,
    "pebbles": -14.0, "cave_in": -11.0,
    "swing": -14.0, "hit": -10.0, "hurt": -10.0, "block": -11.0, "foe_die": -11.0,
    "growl": -10.0, "screech": -14.0, "hiss": -15.0,
    "cast": -13.0, "splash": -12.0, "reel": -18.0,
    "fire_feed": -12.0, "split": -13.0, "smelt": -11.0, "craft": -14.0, "cloth": -15.0, "cook": -15.0,
    "feed": -17.0, "sweep": -16.0, "cleanse": -13.0, "sleep": -13.0, "collapse": -7.0,
    "chop": -10.0, "pick": -11.0, "hoe": -13.0, "tree_fall": -8.0, "rock_break": -9.0,
}


# ---- Building blocks ----

def t_axis(seconds):
    return np.arange(int(seconds * SR)) / SR


def silence(seconds):
    return np.zeros(int(seconds * SR))


def env(n, attack, decay):
    """A quick rise and an exponential fall, in seconds of attack and decay rate per second."""
    t = np.arange(n) / SR
    a = np.clip(t / max(attack, 1e-4), 0.0, 1.0)
    return a * np.exp(-decay * t)


def noise(seconds):
    return RNG.uniform(-1.0, 1.0, int(seconds * SR))


def biquad(x, kind, f, q=0.707):
    """A two-pole filter (low, high or band pass). f can be one frequency or an array that sweeps over the sound."""
    f = np.broadcast_to(np.asarray(f, dtype=float), x.shape)
    y = np.zeros_like(x)
    x1 = x2 = y1 = y2 = 0.0
    block = 64  # the sweep moves in small steps; recomputing the filter every sample is slow and sounds the same
    for start in range(0, len(x), block):
        w = 2 * np.pi * min(f[start], SR * 0.45) / SR
        alpha = np.sin(w) / (2 * q)
        cw = np.cos(w)
        if kind == "low":
            b0, b1, b2 = (1 - cw) / 2, 1 - cw, (1 - cw) / 2
        elif kind == "high":
            b0, b1, b2 = (1 + cw) / 2, -(1 + cw), (1 + cw) / 2
        else:
            b0, b1, b2 = alpha, 0.0, -alpha
        a0, a1, a2 = 1 + alpha, -2 * cw, 1 - alpha
        b0, b1, b2, a1, a2 = b0 / a0, b1 / a0, b2 / a0, a1 / a0, a2 / a0
        for i in range(start, min(start + block, len(x))):
            xi = x[i]
            yi = b0 * xi + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
            x2, x1, y2, y1 = x1, xi, y1, yi
            y[i] = yi
    return y


def lp(x, f, q=0.707):
    return biquad(x, "low", f, q)


def hp(x, f, q=0.707):
    return biquad(x, "high", f, q)


def bp(x, f, q=1.0):
    return biquad(x, "band", f, q)


def modal(freqs, decays, amps, seconds):
    """Struck wood, stone or metal: a few partials, each fading at its own rate."""
    t = t_axis(seconds)
    out = np.zeros(len(t))
    for f, d, a in zip(freqs, decays, amps):
        out += a * np.sin(2 * np.pi * f * t + RNG.uniform(0, 2 * np.pi)) * np.exp(-d * t)
    return out * np.clip(t / 0.0005, 0.0, 1.0)


def grains(seconds, rate, decay):
    """A crackly envelope: random little impulses, each dying away. Multiply noise by it for crunch and rustle."""
    n = int(seconds * SR)
    hits = (RNG.random(n) < rate / SR) * RNG.uniform(0.3, 1.0, n)
    kernel = np.exp(-np.arange(int(decay * 6 * SR) + 1) / (decay * SR))
    return np.convolve(hits, kernel)[:n]


def pluck(f, seconds, damp=0.5):
    """A plucked string (Karplus-Strong). Higher damp keeps it ringing longer and brighter."""
    period = int(SR / f)
    buf = RNG.uniform(-1.0, 1.0, period)
    out = np.zeros(int(seconds * SR))
    for i in range(len(out)):
        j = i % period
        nxt = buf[(j + 1) % period]
        out[i] = buf[j]
        buf[j] = 0.996 * (damp * buf[j] + (1 - damp) * nxt)
    return out


def mix(*parts):
    """Adds sounds of different lengths together, all starting at once."""
    out = np.zeros(max(len(p) for p in parts))
    for p in parts:
        out[: len(p)] += p
    return out


def place(out, x, start, gain=1.0):
    """Adds x into out at start seconds, trimming anything past the end."""
    i = int(start * SR)
    end = min(len(out), i + len(x))
    out[i:end] += x[: end - i] * gain
    return out


def reverb(x, seconds, wet, tone=5000):
    """A soft space around the sound: x convolved with a short burst of fading, darkened noise."""
    n = int(seconds * SR)
    ir = lp(RNG.uniform(-1.0, 1.0, n), tone) * np.exp(-6.9 * np.arange(n) / n)
    ir[: int(0.008 * SR)] = 0.0  # a small gap before the reflections, so the dry hit stays crisp
    ir /= np.sqrt(np.sum(ir ** 2))
    size = len(x) + n
    wet_sig = np.fft.irfft(np.fft.rfft(x, size) * np.fft.rfft(ir, size), size)[:size]
    return np.concatenate([x, np.zeros(n)]) + wet_sig * wet


def finish(x, fade=0.01):
    """Fades the tail so nothing clicks, and trims trailing silence."""
    x = x - np.mean(x)
    loud = np.nonzero(np.abs(x) > 1e-3 * np.max(np.abs(x) + 1e-12))[0]
    if len(loud):
        x = x[: loud[-1] + 1]
    k = min(len(x), int(fade * SR))
    x[len(x) - k:] *= np.linspace(1.0, 0.0, k)
    return x


# ---- The sounds ----

def step():
    # A soft footfall on packed dirt: heel then toe, with a little grit.
    out = silence(0.16)
    for start, gain in [(0.0, 1.0), (0.032, 0.55)]:
        fall = bp(noise(0.08), 420, 0.8) * env(int(0.08 * SR), 0.001, 70)
        thump = modal([72, 118], [70, 90], [0.7, 0.3], 0.08)
        place(out, fall + thump, start, gain)
    grit = bp(noise(0.1) * grains(0.1, 500, 0.0015), 2200, 0.9) * env(int(0.1 * SR), 0.004, 35)
    place(out, grit, 0.004, 0.35)
    return reverb(out, 0.15, 0.08, 2500)


def plant():
    # A trowel bites the soil, then a pat to firm it.
    out = silence(0.4)
    dig = bp(noise(0.16) * grains(0.16, 320, 0.004), 950, 0.8) * env(int(0.16 * SR), 0.006, 16)
    place(out, dig, 0.0, 1.0)
    place(out, modal([92, 158, 240], [35, 50, 70], [1.0, 0.4, 0.15], 0.2), 0.005, 0.7)
    pat = mix(bp(noise(0.06), 480, 1.0) * env(int(0.06 * SR), 0.001, 75), modal([115, 190], [60, 80], [0.6, 0.2], 0.08))
    place(out, pat, 0.2, 0.8)
    return reverb(out, 0.2, 0.08, 3000)


def harvest():
    # A root tearing loose, a leafy shake, and a soft plucked note for the reward.
    out = silence(0.7)
    tear = lp(hp(noise(0.12) * grains(0.12, 700, 0.002), 900), 4500) * env(int(0.12 * SR), 0.03, 14)
    place(out, tear, 0.0, 0.6)
    pop = np.sin(2 * np.pi * np.cumsum(np.linspace(140, 300, int(0.09 * SR))) / SR) * env(int(0.09 * SR), 0.003, 45)
    place(out, pop, 0.09, 0.9)
    leaves = bp(noise(0.2) * grains(0.2, 900, 0.003), 3400, 0.7) * env(int(0.2 * SR), 0.01, 16)
    place(out, leaves, 0.1, 0.35)
    note = lp(pluck(392.0, 0.55, 0.55), 2600) * env(int(0.55 * SR), 0.002, 6)
    place(out, note, 0.11, 0.4)
    return reverb(out, 0.35, 0.12, 4000)


def water():
    # A watering can: a pattering stream with bubbly drops in it.
    length = 0.62
    n = int(length * SR)
    t = t_axis(length)
    shape = np.clip(t / 0.05, 0, 1) * np.clip((length - t) / 0.18, 0, 1)
    wobble = 1.0 + 0.35 * np.sin(2 * np.pi * 9 * t) * np.sin(2 * np.pi * 2.3 * t)
    stream = bp(noise(length), 1500, 0.9) * 0.6 + bp(noise(length), 4200, 1.2) * 0.25
    stream = stream * grains(length, 1800, 0.004) * shape * wobble
    out = stream.copy()
    for _ in range(26):
        start = RNG.uniform(0.02, length - 0.08)
        f0 = RNG.uniform(500, 1100)
        drop_len = int(0.03 * SR)
        f = np.linspace(f0, f0 * 2.1, drop_len)
        drop = np.sin(2 * np.pi * np.cumsum(f) / SR) * env(drop_len, 0.001, 140)
        place(out, drop, start, RNG.uniform(0.08, 0.22))
    return reverb(out[:n], 0.25, 0.1, 5000)


def eat():
    # Two crunchy bites, then a little chewing.
    out = silence(0.6)
    for start, gain in [(0.0, 1.0), (0.21, 0.85)]:
        crunch = lp(bp(noise(0.12) * grains(0.12, 1100, 0.0012), 2400, 0.7), 6500) * env(int(0.12 * SR), 0.002, 26)
        body = bp(noise(0.08) * grains(0.08, 600, 0.002), 700, 0.9) * env(int(0.08 * SR), 0.002, 40)
        place(out, mix(crunch, body * 0.7), start, gain)
    for start in [0.42, 0.5]:
        chew = bp(noise(0.05), 900, 1.2) * env(int(0.05 * SR), 0.01, 60)
        place(out, chew, start, 0.25)
    return reverb(out, 0.15, 0.06, 3000)


def drink():
    # Two gulps: a rising bubble in the throat and a soft swallow.
    out = silence(0.6)
    for start, gain in [(0.0, 1.0), (0.27, 0.8)]:
        glen = int(0.11 * SR)
        f = 180 + 230 * (np.linspace(0, 1, glen) ** 0.6)
        gulp = np.sin(2 * np.pi * np.cumsum(f) / SR) * env(glen, 0.012, 22)
        slosh = bp(noise(0.1) * grains(0.1, 500, 0.003), 950, 2.0) * env(int(0.1 * SR), 0.005, 30)
        swallow = lp(noise(0.05), 500) * env(int(0.05 * SR), 0.004, 60)
        place(out, gulp, start, gain)
        place(out, slosh, start + 0.01, gain * 0.35)
        place(out, swallow, start + 0.1, gain * 0.5)
    return reverb(out, 0.15, 0.05, 2500)


def repair():
    # Two hammer taps on a nail in old wood.
    out = silence(0.55)
    for start, gain in [(0.0, 1.0), (0.22, 0.8)]:
        wood = modal([185, 420, 760, 1180], [32, 48, 70, 95], [1.0, 0.55, 0.3, 0.15], 0.3)
        nail = modal([2950, 4180], [26, 34], [0.18, 0.08], 0.3)
        click = hp(noise(0.004), 2500) * 0.5
        place(out, wood + nail, start, gain)
        place(out, click, start, gain)
    return reverb(out, 0.3, 0.15, 3500)


def coin():
    # A few coins chinking together.
    out = silence(0.55)
    for start in [0.0, 0.06, 0.13, 0.17]:
        f = RNG.uniform(2300, 3100)
        ring = modal([f, f * 1.47, f * 2.09, f * 2.74], [14, 18, 24, 30], [1.0, 0.5, 0.3, 0.15], 0.4)
        place(out, mix(ring, hp(noise(0.003), 4000) * 0.6), start, RNG.uniform(0.55, 1.0))
    return reverb(out, 0.4, 0.15, 6000)


def panel():
    # A soft leather and paper swish, like opening a worn book.
    length = 0.24
    n = int(length * SR)
    sweep = np.linspace(700, 2400, n)
    swish = bp(noise(length), sweep, 0.9) * env(n, 0.07, 14)
    flick = hp(noise(0.012), 1800) * env(int(0.012 * SR), 0.001, 300)
    out = place(np.concatenate([swish, silence(0.05)]), flick, 0.17, 0.25)
    return reverb(out, 0.2, 0.08, 3500)


def tick():
    # A small wooden click for menu moves.
    click = modal([1250, 2750], [190, 280], [1.0, 0.35], 0.06)
    return reverb(mix(click, hp(noise(0.0015), 3000) * 0.3), 0.1, 0.05, 4000)


def chime():
    # A wistful music-box run for achievements: D, F, A, then a high E.
    out = silence(1.6)
    for start, f in [(0.0, 587.33), (0.13, 698.46), (0.26, 880.0), (0.42, 1318.5)]:
        tine = modal([f, f * 2.0, f * 3.0, f * 5.4], [4.5, 7, 11, 18], [1.0, 0.25, 0.1, 0.06], 1.2)
        place(out, mix(tine, hp(noise(0.002), 3000) * 0.05), start, 1.0)
    return reverb(out, 1.2, 0.3, 4500)


def bleat():
    # A goat's "meh-eh": a buzzy voice through vowel formants, with the warble goats have.
    length = 0.7
    t = t_axis(length)
    contour = 340 + 70 * np.sin(np.pi * np.clip(t / 0.25, 0, 1)) - 60 * np.clip((t - 0.25) / 0.45, 0, 1)
    f0 = contour + 10 * np.sin(2 * np.pi * 7 * t)
    phase = 2 * np.pi * np.cumsum(f0) / SR
    voice = sum(np.sin(k * phase) / k for k in range(1, 14))
    warble = 1.0 - 0.55 * (0.5 + 0.5 * np.sin(2 * np.pi * 21 * t))
    voice = voice * warble
    vowel = bp(voice, 650, 4) * 1.0 + bp(voice, 1150, 5) * 0.7 + bp(voice, 2450, 6) * 0.35
    breath = bp(noise(length), 1800, 0.8) * 0.06
    shape = np.clip(t / 0.05, 0, 1) * np.clip((length - t) / 0.2, 0, 1)
    return reverb((vowel + breath) * shape, 0.5, 0.12, 4000)


def buzz():
    # A dull "nuh-uh" for things that can't be done.
    out = silence(0.3)
    for start, f in [(0.0, 116.0), (0.13, 104.0)]:
        t = t_axis(0.1)
        saw = ((t * f) % 1.0 - 0.5) + ((t * f * 1.01) % 1.0 - 0.5)
        place(out, lp(saw, 700) * env(len(t), 0.004, 18), start, 1.0)
    return reverb(out, 0.15, 0.06, 2500)


def thunder():
    # A distant crack, then rolling rumbles fading into the hills.
    length = 4.5
    n = int(length * SR)
    t = t_axis(length)
    rolls = np.zeros(n)
    for centre, width, gain in [(0.15, 0.25, 1.0), (0.9, 0.5, 0.75), (1.8, 0.7, 0.55), (2.8, 0.9, 0.3)]:
        rolls += gain * np.exp(-((t - centre) / width) ** 2)
    rumble = lp(noise(length), 110, 0.9) * 1.6 + lp(noise(length), 320) * 0.35
    rumble = rumble * rolls * np.clip(t / 0.04, 0, 1)
    crack = lp(hp(noise(0.5) * grains(0.5, 400, 0.006), 500), 2500) * env(int(0.5 * SR), 0.004, 7)
    out = place(rumble, crack, 0.02, 0.35)
    return reverb(out, 2.0, 0.35, 1500)


def door():
    # The farmhouse door: a creaky hinge, then the latch.
    out = silence(0.9)
    creak_len = 0.5
    t = t_axis(creak_len)
    rate = 30 + 45 * np.sin(np.pi * t / creak_len) + RNG.normal(0, 4, len(t))
    pulses = np.zeros(len(t))
    pulses[np.nonzero(np.diff(np.floor(np.cumsum(rate) / SR)))[0]] = 1.0
    creak = bp(pulses, 520, 9) + bp(pulses, 1350, 11) * 0.7 + bp(pulses, 2700, 9) * 0.3
    creak *= np.clip(t / 0.06, 0, 1) * np.clip((creak_len - t) / 0.1, 0, 1)
    place(out, creak, 0.0, 1.0)
    latch = mix(modal([140, 330, 610], [30, 45, 70], [1.0, 0.5, 0.25], 0.3), modal([3200], [80], [0.25], 0.1))
    place(out, mix(latch, hp(noise(0.005), 2000) * 0.5), 0.52, 1.1)
    return reverb(out, 0.4, 0.2, 3000)


def strike():
    # An axe or pick biting wood or stone: a solid thunk, a crack, and a few chips.
    out = silence(0.4)
    thunk = modal([150, 360, 680, 1230], [28, 42, 60, 85], [0.6, 0.7, 0.6, 0.4], 0.35)
    crack = hp(noise(0.006), 1500) * env(int(0.006 * SR), 0.0005, 400)
    edge = modal([2650, 3900], [32, 45], [0.12, 0.06], 0.35)
    chips = bp(noise(0.15) * grains(0.15, 220, 0.002), 3000, 0.8) * env(int(0.15 * SR), 0.01, 20)
    place(out, thunk + edge, 0.0, 1.0)
    place(out, crack, 0.0, 0.8)
    place(out, chips, 0.01, 0.4)
    return reverb(out, 0.35, 0.12, 3000)


def gather():
    # Pulling at brush: leafy rustles and a twig snapping.
    out = silence(0.4)
    for start, gain in [(0.0, 1.0), (0.11, 0.8), (0.21, 0.65)]:
        rustle = lp(bp(noise(0.1) * grains(0.1, 900, 0.0025), 2700, 0.7), 6000) * env(int(0.1 * SR), 0.012, 28)
        place(out, rustle, start, gain)
    snap = mix(hp(noise(0.004), 2500), modal([1750, 2600], [140, 190], [0.6, 0.3], 0.05))
    place(out, snap, 0.16, 0.7)
    return reverb(out, 0.2, 0.08, 4000)


# ---- Voices and creatures ----

def harmonics(f0, count, tilt=1.0):
    """A buzzy voice: f0 (an array, one value per sample) with count harmonics, each weaker by tilt."""
    phase = 2 * np.pi * np.cumsum(f0) / SR
    return sum(np.sin(k * phase) / k ** tilt for k in range(1, count + 1))


def caw(length, f_start, f_end):
    t = t_axis(length)
    f0 = np.linspace(f_start, f_end, len(t)) + 18 * np.sin(2 * np.pi * 31 * t)
    rough = 0.65 + 0.35 * np.sin(2 * np.pi * 68 * t + 3 * np.sin(2 * np.pi * 23 * t))
    src = harmonics(f0, 18, 0.8) * rough + bp(noise(length), 1800, 1.2) * 1.5
    voice = bp(src, 1250, 3) + bp(src, 2150, 4) * 0.6 + bp(src, 3400, 5) * 0.25
    return voice * np.clip(t / 0.015, 0, 1) * np.clip((length - t) / 0.13, 0, 1) ** 1.5


def crow():
    # A crow calling twice from somewhere near.
    out = silence(1.0)
    place(out, caw(0.3, 580, 450), 0.0)
    place(out, caw(0.26, 540, 430), 0.42, 0.85)
    return reverb(out, 1.0, 0.3, 4000)


def crow_far():
    # Crows across the fields: three thin caws, softened by distance.
    out = silence(1.5)
    for i, start in enumerate([0.0, 0.4, 0.82]):
        place(out, caw(0.26, 560 - i * 20, 440), start, 1.0 - i * 0.15)
    return reverb(lp(out, 2200), 1.4, 0.6, 2500)


def owl():
    # An owl in the dark wood: hoo, hoo-hoo, hooo.
    out = silence(1.8)
    for start, length in [(0.0, 0.32), (0.55, 0.16), (0.76, 0.16), (0.98, 0.5)]:
        t = t_axis(length)
        f0 = 370 + 25 * np.clip(t / 0.06, 0, 1) - 30 * (t / length)
        note = harmonics(f0, 3, 2.5) * np.clip(t / 0.05, 0, 1) * np.clip((length - t) / 0.12, 0, 1)
        place(out, lp(note + bp(noise(length), 900, 1.5) * 0.05, 1500), start)
    return reverb(out, 1.6, 0.5, 2000)


def howl():
    # Something howling far off: long, rising, then sinking away.
    length = 2.8
    t = t_axis(length)
    rise = np.interp(t, [0, 0.4, 1.4, 2.8], [290, 520, 470, 300])
    voice = harmonics(rise + 6 * np.sin(2 * np.pi * 5 * t), 6, 1.5)
    voice = bp(voice, 520, 2) + bp(voice, 950, 3) * 0.4
    voice *= np.clip(t / 0.3, 0, 1) * np.clip((length - t) / 0.9, 0, 1)
    return reverb(lp(voice, 1800), 2.5, 0.8, 1800)


def snap_far():
    # A branch snapping somewhere in the trees.
    crack = lp(hp(noise(0.01), 1200), 3500) * env(int(0.01 * SR), 0.0005, 250)
    out = np.concatenate([mix(crack, modal([900, 1500], [90, 140], [0.4, 0.2], 0.08)), silence(0.15)])
    place(out, lp(hp(noise(0.006), 1500), 3000), 0.09, 0.5)
    return reverb(out, 1.2, 0.7, 2500)


def steps_behind():
    # Slow footsteps in the leaves, somewhere behind you.
    out = silence(2.2)
    for i, start in enumerate([0.0, 0.62, 1.24, 1.8]):
        crunch = lp(bp(noise(0.14) * grains(0.14, 700, 0.003), 1600, 0.8), 3500) * env(int(0.14 * SR), 0.01, 18)
        place(out, mix(crunch, modal([65, 110], [40, 60], [0.6, 0.3], 0.12)), start, 1.0 - 0.12 * i)
    return reverb(out, 1.0, 0.45, 2000)


def whisper():
    # Breathy, wordless whispering that seems to shape syllables.
    length = 1.9
    n = int(length * SR)
    t = t_axis(length)
    walk = np.cumsum(RNG.normal(0, 1, n))
    walk = (walk - walk.min()) / (np.ptp(walk) + 1e-9)
    breath = noise(length)
    voice = bp(breath, 600 + 900 * walk, 6) + bp(breath, 1700 + 1300 * walk[::-1], 7) * 0.7
    syll = np.clip(np.sin(2 * np.pi * (4.3 * t + 0.4 * np.sin(2 * np.pi * 0.9 * t))), 0, 1) ** 1.5
    shape = np.clip(t / 0.2, 0, 1) * np.clip((length - t) / 0.4, 0, 1)
    return reverb(voice * syll * shape, 1.2, 0.5, 5000)


def heartbeat():
    # A heavy heartbeat: lub, dub.
    out = silence(0.75)
    for start, gain in [(0.0, 1.0), (0.27, 0.65)]:
        place(out, lp(modal([48, 72, 110], [18, 25, 40], [1.0, 0.5, 0.15], 0.35), 220), start, gain)
    return out


def sting():
    # A low swell of dread when something is out there.
    length = 4.2
    t = t_axis(length)
    swell = np.clip(t / 0.7, 0, 1) ** 2 * np.exp(-0.9 * np.clip(t - 0.7, 0, None))
    cluster = sum(a * harmonics(np.full(len(t), f), 4, 1.6) for f, a in [(55.0, 1.0), (58.3, 0.8), (82.4, 0.5), (116.5, 0.35)])
    bowed = bp(noise(length), 3100, 14) * 0.6 * (0.5 + 0.5 * np.sin(2 * np.pi * 3.1 * t))
    return reverb((lp(cluster, 900) + bowed) * swell, 2.5, 0.5, 2500)


def knock():
    # Three slow knocks against the house wall.
    out = silence(2.4)
    for start in [0.0, 0.85, 1.7]:
        hit_ = modal([105, 240, 450, 820], [22, 32, 48, 70], [1.0, 0.6, 0.3, 0.12], 0.4)
        thud = lp(noise(0.03), 600) * env(int(0.03 * SR), 0.001, 90)
        place(out, mix(hit_, thud * 0.6), start)
    return reverb(out, 0.9, 0.35, 2200)


def hen():
    # A hen muttering: buk, buk, bu-kaaw.
    out = silence(0.95)
    for start, length, f in [(0.0, 0.07, 520), (0.16, 0.07, 540), (0.33, 0.06, 560), (0.42, 0.28, 640)]:
        t = t_axis(length)
        src = harmonics(f + np.linspace(0, 120 if length > 0.1 else -40, len(t)), 12, 1.0)
        voice = bp(src, 1100, 3) + bp(src, 2300, 4) * 0.5
        place(out, voice * np.clip(t / 0.008, 0, 1) * np.clip((length - t) / 0.03, 0, 1), start)
    return reverb(out, 0.4, 0.15, 4000)


# ---- The house at night ----

def stick_slip(length, rate_from, rate_to, bands):
    """A creak: a stuttering train of tiny jolts, rung through the resonances of a board."""
    t = t_axis(length)
    rate = np.interp(t, [0, length * 0.5, length], [rate_from, rate_to, rate_from * 0.8]) + RNG.normal(0, 3, len(t))
    pulses = np.zeros(len(t))
    jolts = np.nonzero(np.diff(np.floor(np.cumsum(rate) / SR)))[0]
    pulses[jolts] = RNG.uniform(0.6, 1.0, len(jolts))
    out = sum(bp(pulses, f, q) * a for f, q, a in bands)
    return out * np.clip(t / 0.08, 0, 1) * np.clip((length - t) / 0.12, 0, 1)


def creak():
    # A floorboard giving under a weight that isn't yours.
    return reverb(stick_slip(0.7, 55, 110, [(380, 10, 1.0), (880, 12, 0.6), (1900, 10, 0.2)]), 0.6, 0.3, 3000)


def creak_high():
    # A beam or a door frame, tightening in the cold.
    return reverb(stick_slip(0.5, 90, 160, [(720, 12, 1.0), (1500, 14, 0.5)]), 0.6, 0.3, 3500)


def settle():
    # The whole house groaning as it settles.
    groan = stick_slip(1.5, 14, 26, [(150, 6, 1.0), (260, 8, 0.6), (520, 9, 0.2)])
    return reverb(lp(groan, 900), 0.9, 0.35, 1500)


def thunder_in():
    # Thunder heard from inside: dull, heavy, and the window rattling in its frame.
    rumble = lp(thunder(), 380, 0.8)
    rattle = bp(noise(0.6) * grains(0.6, 80, 0.006), 2200, 2.0) * env(int(0.6 * SR), 0.05, 4)
    return place(rumble, rattle, 0.2, 0.25)


# ---- The cave ----

def droplet(f0):
    drop_len = int(0.025 * SR)
    f = np.linspace(f0, f0 * 2.4, drop_len)
    return np.sin(2 * np.pi * np.cumsum(f) / SR) * env(drop_len, 0.0005, 160)


def drip():
    # A single drop falling into a still pool, deep in the rock.
    return reverb(droplet(900), 2.2, 0.9, 3500)


def drip_low():
    return reverb(mix(droplet(620), lp(noise(0.01), 1500) * 0.1), 2.2, 0.9, 3000)


def cave_rumble():
    # The mountain shifting somewhere far off, and grit trickling down.
    length = 2.6
    t = t_axis(length)
    rumble = lp(noise(length), 85, 0.9) * np.exp(-((t - 0.8) / 0.6) ** 2)
    trickle = np.clip((t - 0.9) / 0.4, 0, 1) * np.exp(-1.5 * np.clip(t - 1.3, 0, None))
    grit = bp(noise(length) * grains(length, 120, 0.003), 2200, 0.8) * trickle
    return reverb(rumble * 2.0 + grit * 0.25, 2.0, 0.6, 1500)


def skitter():
    # Claws clicking over stone, darting away.
    length = 0.9
    t = t_axis(length)
    clicks = hp(noise(length) * grains(length, 55, 0.0008), 2500)
    return reverb(clicks * np.sin(np.pi * t / length) ** 0.7, 1.8, 0.7, 4000)


def cave_moan():
    # Air moving through the tunnels, almost a voice.
    length = 3.2
    t = t_axis(length)
    f = np.interp(t, [0, 1.2, 2.2, 3.2], [290, 420, 360, 260])
    whistle = bp(noise(length), f, 18) * 2.5 + bp(noise(length), f * 2.01, 20) * 0.6
    return reverb(whistle * np.clip(t / 0.8, 0, 1) * np.clip((length - t) / 1.0, 0, 1), 2.4, 0.7, 2000)


def pebbles():
    # A few stones skittering down a slope.
    out = silence(1.0)
    start, gap = 0.0, 0.16
    for i in range(7):
        f = RNG.uniform(1800, 3200)
        place(out, modal([f, f * 1.6], [70, 90], [1.0, 0.4], 0.08), start, 1.0 - i * 0.11)
        start += gap
        gap *= 0.75
    return reverb(out, 1.8, 0.7, 3500)


def cave_in():
    # Stepping into the cave: the air closes in and the sound comes back hollow.
    length = 1.6
    t = t_axis(length)
    gust = lp(noise(length), 300) * np.clip(t / 0.3, 0, 1) * np.exp(-2.2 * t)
    return reverb(place(gust * 1.4, droplet(1000), 0.5, 0.3), 2.2, 0.7, 2000)


# ---- Fighting ----

def swing():
    # A blade cutting the air.
    length = 0.26
    t = t_axis(length)
    f = np.interp(t, [0, 0.1, length], [500, 1700, 600])
    return reverb(bp(noise(length), f, 1.4) * np.sin(np.pi * t / length) ** 2, 0.15, 0.05, 4000)


def hit():
    # A blow landing on something that isn't quite flesh.
    thud = modal([85, 140, 230], [30, 45, 60], [1.0, 0.5, 0.2], 0.25)
    squelch = bp(noise(0.08) * grains(0.08, 500, 0.003), 700, 1.2) * env(int(0.08 * SR), 0.002, 40)
    return reverb(mix(thud, squelch * 0.8, hp(noise(0.003), 2000) * 0.4), 0.25, 0.1, 2500)


def hurt():
    # You take a hit: an impact and a short, pained breath.
    length = 0.3
    t = t_axis(length)
    voice = harmonics(np.linspace(150, 105, len(t)), 10, 1.2)
    voice = bp(voice, 400, 3) + bp(voice, 850, 4) * 0.4 + bp(noise(length), 1200, 1.0) * 0.4
    voice *= np.clip(t / 0.02, 0, 1) * np.clip((length - t) / 0.12, 0, 1)
    thump = modal([70, 120], [35, 50], [1.0, 0.4], 0.2)
    return reverb(mix(place(silence(length + 0.05), voice, 0.04, 0.8), thump), 0.25, 0.08, 2500)


def block():
    # A blow turned aside: a solid knock with a ring of metal.
    wood = modal([170, 390, 700], [30, 45, 60], [1.0, 0.5, 0.25], 0.3)
    ring = modal([1650, 2480, 3710], [9, 13, 18], [0.35, 0.2, 0.1], 0.5)
    return reverb(mix(wood, ring, hp(noise(0.004), 2500) * 0.6), 0.3, 0.15, 3500)


def foe_die():
    # A creature collapsing: a falling wail and a crumbling, dry sound.
    length = 1.0
    t = t_axis(length)
    voice = harmonics(np.interp(t, [0, length], [260, 90]) + 12 * np.sin(2 * np.pi * 7 * t), 12, 1.0)
    voice = (bp(voice, 600, 3) + bp(voice, 1300, 4) * 0.5) * np.clip(t / 0.03, 0, 1) * np.exp(-3 * t)
    after = np.clip((t - 0.25) / 0.1, 0, 1) * np.exp(-3 * np.clip(t - 0.25, 0, None))
    crumble = bp(noise(length) * grains(length, 300, 0.003), 1500, 0.8) * after
    return reverb(voice + crumble * 0.5, 0.8, 0.3, 3000)


def growl():
    # A low, wet growl from the hollow things in the wood.
    length = 1.1
    t = t_axis(length)
    f0 = 72 + 10 * np.sin(2 * np.pi * 1.3 * t) + 4 * RNG.normal(0, 1, len(t))
    rough = 0.5 + 0.5 * np.abs(np.sin(2 * np.pi * 27 * t))
    src = harmonics(f0, 30, 0.9) * rough + bp(noise(length), 500, 1.0) * 0.6
    voice = (bp(src, 380, 3) + bp(src, 900, 4) * 0.5) * np.clip(t / 0.15, 0, 1) * np.clip((length - t) / 0.3, 0, 1)
    return reverb(voice, 0.6, 0.25, 2000)


def screech():
    # A bat shrieking past: three quick, high chirps.
    out = silence(0.45)
    for start in [0.0, 0.11, 0.2]:
        f = np.linspace(7200, 3800, int(0.05 * SR))
        chirp = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.sin(np.pi * np.arange(len(f)) / len(f))
        place(out, chirp, start, RNG.uniform(0.7, 1.0))
    return reverb(out, 0.6, 0.3, 6000)


def hiss():
    # A lizard or snake hissing, with a dry rattle under it.
    length = 0.8
    t = t_axis(length)
    breath = lp(hp(noise(length), 3200), 9000) * np.clip(t / 0.06, 0, 1) * np.clip((length - t) / 0.3, 0, 1)
    rattle = bp(noise(length) * (0.5 + 0.5 * np.sign(np.sin(2 * np.pi * 38 * t))), 3000, 1.0)
    return reverb(breath + rattle * 0.3 * np.clip(t / 0.1, 0, 1) * np.exp(-2 * t), 0.3, 0.1, 5000)


# ---- Fishing ----

def plop(f0, gain):
    spray = bp(noise(0.12) * grains(0.12, 1500, 0.002), 1300, 0.8) * env(int(0.12 * SR), 0.003, 30)
    return mix(droplet(f0) * gain, spray * 0.6, lp(noise(0.04), 300) * env(int(0.04 * SR), 0.002, 60) * 0.5)


def cast():
    # The rod whips, the line sings out, and the float drops in.
    out = silence(0.9)
    place(out, swing(), 0.0, 0.7)
    zip_len = 0.35
    t = t_axis(zip_len)
    line = np.sin(2 * np.pi * np.cumsum(np.interp(t, [0, zip_len], [2200, 1300])) / SR) * np.exp(-5 * t) * 0.08
    place(out, line, 0.08)
    place(out, plop(450, 0.4), 0.5)
    return reverb(out, 0.6, 0.2, 4000)


def splash():
    # A fish thrashing up out of the water.
    out = silence(0.8)
    for start, gain in [(0.0, 1.0), (0.12, 0.7), (0.3, 0.5)]:
        place(out, plop(RNG.uniform(350, 600), 0.5), start, gain)
    for _ in range(14):
        place(out, droplet(RNG.uniform(900, 1800)), RNG.uniform(0.15, 0.6), RNG.uniform(0.05, 0.15))
    return reverb(out, 0.6, 0.2, 4000)


def reel():
    # The reel ratcheting as you wind in.
    out = silence(0.7)
    for i in range(16):
        place(out, modal([3100, 4700], [500, 700], [1.0, 0.4], 0.02), i * 0.04, 0.6 + 0.4 * (i % 2))
    return reverb(out, 0.2, 0.06, 5000)


# ---- Fire, crafting, and chores ----

def fire_feed():
    # A log dropped into the grate, and the fire flaring up around it.
    length = 1.4
    t = t_axis(length)
    log = modal([120, 290, 540], [25, 35, 50], [1.0, 0.5, 0.2], 0.4)
    whoomph = lp(noise(length), 400) * np.clip((t - 0.05) / 0.25, 0, 1) * np.exp(-2.5 * np.clip(t - 0.3, 0, None))
    crackle = hp(noise(length) * grains(length, 25, 0.002), 1500) * np.clip((t - 0.1) / 0.2, 0, 1) * np.exp(-1.5 * t)
    return reverb(mix(log, whoomph * 0.8, crackle * 0.8), 0.4, 0.15, 3000)


def split():
    # The axe driving into a round and the halves knocking apart.
    out = silence(0.7)
    place(out, chop(), 0.0)
    place(out, lp(hp(noise(0.02), 800), 4000) * env(int(0.02 * SR), 0.0005, 150), 0.06, 0.7)
    for start, gain in [(0.24, 0.6), (0.31, 0.45)]:
        place(out, modal([210, 470, 830], [35, 50, 70], [1.0, 0.4, 0.2], 0.2), start, gain)
    return out


def smelt():
    # The furnace roaring, the bar hissing in the trough, and a clink of metal.
    length = 1.6
    t = t_axis(length)
    roar = lp(noise(length), 250, 0.9) * np.clip(t / 0.2, 0, 1) * np.exp(-1.8 * t)
    quench = lp(hp(noise(length), 3000), 9000) * np.clip((t - 0.5) / 0.05, 0, 1) * np.exp(-2.4 * np.clip(t - 0.5, 0, None))
    out = roar * 1.5 + quench * 0.35
    place(out, modal([1450, 2210, 3480], [10, 14, 20], [0.4, 0.25, 0.1], 0.6), 0.32)
    return reverb(out, 0.5, 0.2, 3500)


def craft():
    # Whittling and binding: two knife strokes and a tap to set it.
    out = silence(0.8)
    for start in [0.0, 0.25]:
        stroke_len = 0.18
        t = t_axis(stroke_len)
        scrape = bp(noise(stroke_len) * (0.6 + 0.4 * np.sin(2 * np.pi * 45 * t)), 2600, 1.5) * np.sin(np.pi * t / stroke_len)
        place(out, scrape, start, 0.6)
    place(out, modal([240, 560, 980], [40, 55, 80], [1.0, 0.4, 0.2], 0.2), 0.52)
    return reverb(out, 0.3, 0.12, 3500)


def cloth():
    # Tearing a strip of cloth for a bandage.
    length = 0.45
    t = t_axis(length)
    rip = bp(noise(length) * grains(length, 2500, 0.0008), np.interp(t, [0, length], [1400, 2600]), 1.2)
    return reverb(rip * np.clip(t / 0.05, 0, 1) * np.clip((length - t) / 0.06, 0, 1), 0.2, 0.08, 4000)


def cook():
    # A pan set down and food spitting in hot fat.
    length = 1.5
    t = t_axis(length)
    pan = modal([620, 1490, 2350], [18, 26, 34], [0.6, 0.3, 0.15], 0.5)
    heat = np.clip((t - 0.1) / 0.1, 0, 1) * np.clip((length - t) / 0.4, 0, 1)
    sizzle = lp(hp(noise(length), 2500), 8000) * (0.6 + 0.4 * grains(length, 300, 0.01)) * heat
    pops = hp(noise(length) * grains(length, 20, 0.0015), 1500) * heat
    return reverb(mix(pan, sizzle * 0.3, pops * 0.7), 0.4, 0.12, 4000)


def feed():
    # A handful of feed scattered over the ground.
    length = 0.7
    t = t_axis(length)
    scatter = hp(noise(length) * grains(length, 400, 0.0007), 1800) * np.clip(t / 0.03, 0, 1) * np.exp(-3.5 * t)
    return reverb(scatter, 0.3, 0.1, 5000)


def sweep():
    # Three strokes of a broom on old boards.
    out = silence(1.2)
    for start in [0.0, 0.38, 0.76]:
        stroke_len = 0.3
        t = t_axis(stroke_len)
        stroke = bp(noise(stroke_len) * grains(stroke_len, 1500, 0.001), np.interp(t, [0, stroke_len], [2400, 1500]), 0.8)
        place(out, stroke * np.sin(np.pi * t / stroke_len) ** 1.5, start, 0.8)
    return reverb(out, 0.5, 0.2, 3500)


def cleanse():
    # The offering burns and the house breathes out: a soft rush and a high, clean shimmer.
    length = 2.4
    t = t_axis(length)
    out = bp(noise(length), np.interp(t, [0, length], [600, 2400]), 0.8) * np.sin(np.pi * t / length) ** 2 * 0.5
    for start, f in [(0.3, 1174.7), (0.55, 1568.0), (0.8, 1760.0), (1.1, 2349.3)]:
        place(out, modal([f, f * 2.0], [3.5, 6], [0.3, 0.08], 1.3), start)
    return reverb(out, 1.6, 0.45, 6000)


def sleep():
    # Lying down: a slow, low, falling lullaby.
    out = silence(3.2)
    for start, f in [(0.0, 392.0), (0.6, 329.6), (1.2, 293.7), (1.9, 196.0)]:
        place(out, lp(modal([f, f * 2.0, f * 3.0], [2.2, 4, 6], [1.0, 0.2, 0.05], 2.0), 1800), start, 0.7)
    return reverb(out, 2.0, 0.45, 2500)


def collapse():
    # 03:00 and the mind gives way: a deep boom, a sour ringing, and a pounding heart.
    length = 4.5
    t = t_axis(length)
    boom = lp(noise(length), 70, 1.0) * 3.0 * np.exp(-1.6 * t) + np.sin(2 * np.pi * 38 * t) * np.exp(-2 * t)
    ring = sum(np.sin(2 * np.pi * f * t) * a for f, a in [(622.3, 0.25), (659.3, 0.25), (932.3, 0.12)])
    out = boom + ring * 0.5 * np.clip(t / 0.4, 0, 1) * np.exp(-0.9 * t)
    for start in [1.2, 2.0, 2.8, 3.7]:
        place(out, heartbeat(), start, 0.8)
    return reverb(out, 2.5, 0.4, 2000)


# ---- Tools at work ----
# These play on every swing, in time with the animation, so they need to be clear on small speakers too:
# each has a bright bite on top of its body, not only a low thud.

def chop():
    # An axe biting into a trunk: a sharp crack, a hollow wooden knock, and chips flying.
    bite = bp(noise(0.012), 2600, 0.9) * env(int(0.012 * SR), 0.0003, 260)
    knock = modal([310, 760, 1420, 2280], [38, 55, 80, 110], [0.5, 1.0, 0.8, 0.5], 0.3)
    chips = hp(noise(0.12) * grains(0.12, 260, 0.0015), 2800) * env(int(0.12 * SR), 0.004, 28)
    body = modal([140], [45], [0.2], 0.2)
    return reverb(mix(bite * 2.0, knock, chips * 0.6, body), 0.35, 0.15, 4000)


def pick():
    # A pick hitting stone: a hard clack, a short ring, and grit spraying off.
    clack = modal([1850, 2790, 4060], [60, 80, 110], [1.0, 0.55, 0.3], 0.2)
    crack = bp(noise(0.008), 3500, 0.8) * env(int(0.008 * SR), 0.0003, 350)
    grit = hp(noise(0.15) * grains(0.15, 500, 0.0012), 2500) * env(int(0.15 * SR), 0.004, 22)
    thump = modal([180, 300], [50, 70], [0.6, 0.3], 0.15)
    return reverb(mix(clack, crack * 1.2, grit * 0.35, thump), 0.35, 0.15, 4500)


def hoe():
    # A hoe chopping into the soil and turning it.
    bite = bp(noise(0.02), 1400, 1.0) * env(int(0.02 * SR), 0.0005, 160)
    soil = bp(noise(0.16) * grains(0.16, 600, 0.003), 1100, 0.8) * env(int(0.16 * SR), 0.003, 20)
    thunk = modal([170, 330, 720], [45, 60, 90], [0.4, 0.3, 0.3], 0.15)
    return reverb(mix(bite * 2.0, soil * 1.2, thunk), 0.2, 0.08, 3000)


def tree_fall():
    # The last chop: the trunk cracks and groans, leans, rushes down through the air and hits the ground.
    out = silence(3.4)
    place(out, chop(), 0.0)
    place(out, stick_slip(0.9, 20, 45, [(260, 7, 1.0), (640, 9, 0.6), (1300, 10, 0.25)]), 0.15, 0.9)
    snap = lp(hp(noise(0.25) * grains(0.25, 900, 0.002), 900), 6000) * env(int(0.25 * SR), 0.002, 12)
    place(out, snap, 0.95, 0.9)
    rush_len = 1.0
    t = t_axis(rush_len)
    rush = bp(noise(rush_len) * grains(rush_len, 1200, 0.003), np.interp(t, [0, rush_len], [1500, 3200]), 0.7)
    place(out, rush * np.clip(t / 0.4, 0, 1) * np.clip((rush_len - t) / 0.1, 0, 1), 1.05, 0.7)
    thud = mix(lp(noise(0.8), 160, 0.9) * env(int(0.8 * SR), 0.003, 6) * 2.5, modal([60, 95, 170], [10, 14, 22], [1.0, 0.6, 0.3], 0.8))
    place(out, thud, 2.05)
    branches = mix(hp(noise(0.5) * grains(0.5, 700, 0.002), 1500) * env(int(0.5 * SR), 0.005, 7), bp(noise(0.6), 2400, 0.7) * env(int(0.6 * SR), 0.01, 6))
    place(out, branches, 2.07, 0.5)
    return reverb(out, 1.2, 0.3, 3500)


def rock_break():
    # The rock gives way: a deep crack, then the pieces tumbling apart.
    out = silence(1.4)
    place(out, pick(), 0.0)
    crack = lp(hp(noise(0.05) * grains(0.05, 1500, 0.001), 800), 7000) * env(int(0.05 * SR), 0.0005, 40)
    place(out, crack, 0.02, 0.9)
    place(out, mix(lp(noise(0.3), 220) * env(int(0.3 * SR), 0.002, 14), modal([95, 150], [20, 30], [1.0, 0.5], 0.3)), 0.03, 1.2)
    for _ in range(9):
        f = RNG.uniform(1300, 3000)
        place(out, modal([f, f * 1.6], [70, 95], [1.0, 0.4], 0.08), RNG.uniform(0.08, 0.7), RNG.uniform(0.25, 0.7))
    return reverb(out, 0.6, 0.2, 4000)


SOUNDS = {
    "chop": chop, "pick": pick, "hoe": hoe, "tree_fall": tree_fall, "rock_break": rock_break,
    "step": step, "plant": plant, "harvest": harvest, "water": water, "eat": eat, "drink": drink,
    "repair": repair, "coin": coin, "panel": panel, "tick": tick, "chime": chime, "bleat": bleat,
    "buzz": buzz, "thunder": thunder, "door": door, "strike": strike, "gather": gather,
    "crow": crow, "crow_far": crow_far, "owl": owl, "howl": howl, "snap_far": snap_far, "steps_behind": steps_behind,
    "whisper": whisper, "heartbeat": heartbeat, "sting": sting, "knock": knock, "hen": hen,
    "creak": creak, "creak_high": creak_high, "settle": settle, "thunder_in": thunder_in,
    "drip": drip, "drip_low": drip_low, "cave_rumble": cave_rumble, "skitter": skitter, "cave_moan": cave_moan,
    "pebbles": pebbles, "cave_in": cave_in,
    "swing": swing, "hit": hit, "hurt": hurt, "block": block, "foe_die": foe_die,
    "growl": growl, "screech": screech, "hiss": hiss,
    "cast": cast, "splash": splash, "reel": reel,
    "fire_feed": fire_feed, "split": split, "smelt": smelt, "craft": craft, "cloth": cloth, "cook": cook,
    "feed": feed, "sweep": sweep, "cleanse": cleanse, "sleep": sleep, "collapse": collapse,
}


# ---- Ambient loops ----
# Each loop is built in one piece around a circle: noise is filtered in the frequency domain, every wobble repeats a
# whole number of times, and events and echoes wrap past the end back to the start. So the loops join without a seam.

LOOP_SECONDS = 12.0
AMBIENCE_DIR = os.path.join("audio", "ambience")
LOOP_LOUDNESS = -20.0  # average level in dBFS; the game fades each loop in and out from there


def band(x, lo=None, hi=None):
    """Keeps the part of x between lo and hi Hz, with gentle slopes. Works around the loop, so it never seams."""
    spec = np.fft.rfft(x)
    f = np.fft.rfftfreq(len(x), 1 / SR) + 1e-6
    gain = np.ones_like(f)
    if lo:
        gain /= np.sqrt(1 + (lo / f) ** 4)
    if hi:
        gain /= np.sqrt(1 + (f / hi) ** 4)
    return np.fft.irfft(spec * gain, len(x))


def wave(n, cycles, phase=0.0):
    """A slow swell that repeats exactly cycles times per loop, from 0 to 1."""
    return 0.5 + 0.5 * np.sin(2 * np.pi * cycles * np.arange(n) / n + phase)


def drift(n, max_cycles):
    """A smooth, wandering level between 0 and 1 that comes back to where it started at the loop's end."""
    out = sum(RNG.uniform(0.3, 1.0) * np.sin(2 * np.pi * c * np.arange(n) / n + RNG.uniform(0, 2 * np.pi)) / c
              for c in range(1, max_cycles + 1))
    return (out - out.min()) / (np.ptp(out) + 1e-9)


def scatter(n, x, count, gain=(0.5, 1.0)):
    """Drops count copies of x at random places, wrapping around the end of the loop."""
    out = np.zeros(n)
    for _ in range(count):
        i = RNG.integers(0, n)
        idx = (i + np.arange(len(x))) % n
        out[idx] += x * RNG.uniform(*gain)
    return out


def loop_reverb(x, seconds, wet, tone=4000):
    n = int(seconds * SR)
    ir = lp(RNG.uniform(-1.0, 1.0, n), tone) * np.exp(-6.9 * np.arange(n) / n)
    ir /= np.sqrt(np.sum(ir ** 2))
    wet_sig = np.fft.irfft(np.fft.rfft(x) * np.fft.rfft(ir, len(x)), len(x))
    return x + wet_sig * wet


def loop_noise():
    return RNG.uniform(-1.0, 1.0, int(LOOP_SECONDS * SR))


def amb_wind():
    # Daytime outside: a restless breeze over the fields and the trees stirring.
    n = int(LOOP_SECONDS * SR)
    breeze = band(loop_noise(), 120, 900) * (0.3 + 0.7 * drift(n, 5))
    leaves = band(loop_noise(), 2000, 6000) * (0.2 + 0.8 * drift(n, 7) ** 2) * 0.25
    return breeze + leaves


def amb_night():
    # Night outside: a low, cold wind, quieter than the day's, that sometimes moans through the trees.
    n = int(LOOP_SECONDS * SR)
    low = band(loop_noise(), 60, 400) * (0.4 + 0.6 * drift(n, 4))
    moan = band(loop_noise(), 380, 520) * drift(n, 3) ** 3 * 2.0
    return low + moan


def amb_crickets():
    # Crickets in the long grass, in uneven groups.
    n = int(LOOP_SECONDS * SR)
    out = np.zeros(n)
    for f, rate, cycles in [(4300, 15.0, 7), (4750, 13.0, 5), (3900, 17.0, 9)]:
        t = np.arange(n) / SR
        pulse = np.clip(np.sin(2 * np.pi * rate * t), 0, 1) ** 4
        trill = np.clip(np.sin(2 * np.pi * cycles * np.arange(n) / n + RNG.uniform(0, 6)), 0, 1) ** 0.5
        out += np.sin(2 * np.pi * f * t) * pulse * trill * (0.5 + 0.5 * drift(n, 6))
    return loop_reverb(out * 0.3, 0.8, 0.4, 5000)


def amb_dread():
    # Under the night: a low drone that beats against itself, too slow to call a sound.
    n = int(LOOP_SECONDS * SR)
    t = np.arange(n) / SR
    drone = sum(a * np.sin(2 * np.pi * f * t) for f, a in [(41.25, 1.0), (43.75, 0.8), (61.75, 0.4), (87.5, 0.15)])
    air = band(loop_noise(), 80, 260) * 0.8
    return (drone * 0.5 + air) * (0.5 + 0.5 * drift(n, 3))


def amb_rain():
    # Rain outside: a wash of drops on grass and soil, with heavier spatters.
    n = int(LOOP_SECONDS * SR)
    wash = band(loop_noise(), 500, 7000) * (0.8 + 0.2 * drift(n, 6))
    drops = band(scatter(n, np.exp(-np.arange(200) / 25.0) * RNG.uniform(-1, 1, 200), 3000), 800, 9000)
    patter = band(loop_noise(), 150, 600) * 0.4
    return wash * 0.6 + drops * 0.7 + patter


def amb_roof():
    # Rain on the roof, heard from inside: a soft drumming overhead and drops tapping the window glass.
    n = int(LOOP_SECONDS * SR)
    drum = band(loop_noise(), 120, 1400) * (0.75 + 0.25 * drift(n, 5))
    thuds = band(scatter(n, np.exp(-np.arange(400) / 60.0) * RNG.uniform(-1, 1, 400), 2500), 150, 1200)
    tap_len = int(0.02 * SR)
    t = np.arange(tap_len) / SR
    taps = np.zeros(n)
    for _ in range(160):
        f = RNG.uniform(2300, 3800)
        tap = np.sin(2 * np.pi * f * t) * np.exp(-260 * t)
        taps += scatter(n, tap, 1, (0.2, 1.0))
    gutter = scatter(n, np.sin(2 * np.pi * np.cumsum(np.linspace(700, 1500, 900)) / SR) * np.exp(-np.arange(900) / 180.0), 12)
    return loop_reverb(drum * 0.9 + thuds * 0.6 + taps * 0.18 + gutter * 0.12, 0.6, 0.3, 3000)


def amb_house():
    # Inside the farmhouse: still, cold air, and wind finding the gaps in the boards.
    n = int(LOOP_SECONDS * SR)
    room = band(loop_noise(), 40, 220) * 0.6
    whistle = band(loop_noise(), 640, 760) * drift(n, 4) ** 2 * 3.0
    draught = band(loop_noise(), 200, 900) * (0.3 + 0.7 * drift(n, 3)) * 0.4
    return room + whistle + draught


def amb_fire():
    # The hearth: a low flutter of flame, crackles and the odd pop.
    n = int(LOOP_SECONDS * SR)
    flutter = band(loop_noise(), 60, 380) * (0.6 + 0.4 * drift(n, 20))
    crack_len = 120
    crack = RNG.uniform(-1, 1, crack_len) * np.exp(-np.arange(crack_len) / 18.0)
    crackles = band(scatter(n, crack, 900, (0.1, 1.0)), 1500, 8000)
    pops = band(scatter(n, RNG.uniform(-1, 1, 500) * np.exp(-np.arange(500) / 70.0), 18), 400, 4000)
    return flutter + crackles * 0.5 + pops * 0.6


def amb_cave():
    # Deep in the cave: a heavy, hollow stillness, with air breathing through the far tunnels.
    n = int(LOOP_SECONDS * SR)
    t = np.arange(n) / SR
    hollow = band(loop_noise(), 30, 180) * (0.6 + 0.4 * drift(n, 3))
    breath = band(loop_noise(), 220, 600) * drift(n, 2) ** 2 * 0.8
    hum = (np.sin(2 * np.pi * 55.0 * t) + 0.6 * np.sin(2 * np.pi * 55.5 * t)) * 0.08
    return loop_reverb(hollow + breath + hum, 2.5, 0.5, 1500)


LOOPS = {
    "wind": amb_wind, "night": amb_night, "crickets": amb_crickets, "dread": amb_dread, "rain": amb_rain,
    "roof": amb_roof, "house": amb_house, "fire": amb_fire, "cave": amb_cave,
}


def level(x, target_db):
    """Scales x so its loudest 50 ms sits at target_db, without letting the peak clip."""
    w = int(0.05 * SR)
    loud = max(np.sqrt(np.mean(x[i:i + w] ** 2)) for i in range(0, max(1, len(x) - w), w // 4))
    gain = 10 ** (target_db / 20) / max(loud, 1e-9)
    return x * min(gain, 0.95 / np.max(np.abs(x)))


def write(name, samples, folder=OUT_DIR):
    path = os.path.join(folder, name + ".ogg")
    # Written in small blocks: libsndfile's Vorbis encoder can crash when handed a long sound in one call.
    with sf.SoundFile(path, "w", SR, 1, format="OGG", subtype="VORBIS") as f:
        data = np.clip(samples, -1.0, 1.0)
        for i in range(0, len(data), 8192):
            f.write(data[i:i + 8192])
    return path, len(samples) / SR


def main():
    global RNG
    os.makedirs(OUT_DIR, exist_ok=True)
    for name, make in SOUNDS.items():
        RNG = np.random.default_rng(zlib.crc32(name.encode()))
        samples = level(finish(make()), LOUDNESS[name])
        path, seconds = write(name, samples)
        print("wrote %s (%.2f s)" % (path, seconds))
    os.makedirs(AMBIENCE_DIR, exist_ok=True)
    for name, make in LOOPS.items():
        RNG = np.random.default_rng(zlib.crc32(("loop_" + name).encode()))
        x = make()
        x = x - np.mean(x)
        x *= min(10 ** (LOOP_LOUDNESS / 20) / np.sqrt(np.mean(x ** 2)), 0.95 / np.max(np.abs(x)))
        path, seconds = write(name, x, AMBIENCE_DIR)
        print("wrote %s (%.2f s loop)" % (path, seconds))


if __name__ == "__main__":
    main()
