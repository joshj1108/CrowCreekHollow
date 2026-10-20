"""Renders the farm's sound effects to audio/sfx/*.ogg.

Everything is synthesized here, so the sounds are original and reproducible. Run from the project folder with:
python3 tools/make_sfx.py   (needs numpy and ffmpeg).
"""
import os
import subprocess
import wave

import numpy as np

SR = 32000
OUT_DIR = os.path.join("audio", "sfx")
RNG = np.random.default_rng(90210)


def t_axis(seconds):
    return np.arange(int(seconds * SR)) / SR


def env(n, attack, decay):
    """A quick rise and an exponential fall, in seconds of attack and decay rate per second."""
    t = np.arange(n) / SR
    a = np.clip(t / max(attack, 1e-4), 0.0, 1.0)
    return a * np.exp(-decay * t)


def noise(seconds):
    return RNG.uniform(-1.0, 1.0, int(seconds * SR))


def lowpass(x, a):
    """A one-pole low-pass filter. Smaller a means a darker sound."""
    y = np.zeros_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc += a * (x[i] - acc)
        y[i] = acc
    return y


def sweep(f0, f1, seconds):
    t = t_axis(seconds)
    f = np.linspace(f0, f1, len(t))
    return np.sin(2 * np.pi * np.cumsum(f) / SR)


def tone(f, seconds):
    return np.sin(2 * np.pi * f * t_axis(seconds))


def mix(*parts):
    n = max(len(p) for p in parts)
    out = np.zeros(n)
    for p in parts:
        out[: len(p)] += p
    return out


def delayed(x, seconds):
    pad = np.zeros(int(seconds * SR))
    return np.concatenate([pad, x])


def normalize(x, peak=0.85):
    m = np.max(np.abs(x))
    return x * (peak / m) if m > 0 else x


def step():
    n = noise(0.09)
    return normalize(lowpass(n, 0.08) * env(len(n), 0.002, 45) * 0.9 + tone(110, 0.09) * env(len(n), 0.001, 55) * 0.5, 0.6)


def plant():
    body = sweep(170, 115, 0.22) * env(int(0.22 * SR), 0.003, 22)
    click = lowpass(noise(0.02), 0.5) * env(int(0.02 * SR), 0.001, 200) * 0.5
    return normalize(mix(body, click), 0.6)


def harvest():
    pop = sweep(420, 760, 0.18) * env(int(0.18 * SR), 0.01, 14)
    overtone = sweep(840, 1520, 0.18) * env(int(0.18 * SR), 0.01, 22) * 0.25
    return normalize(mix(pop, overtone), 0.6)


def water():
    hiss = lowpass(noise(0.45), 0.3) - lowpass(noise(0.45), 0.05)
    hiss = hiss * env(len(hiss), 0.02, 6)
    bubbles = np.zeros(int(0.45 * SR))
    for start in [0.08, 0.2, 0.3]:
        bubbles = mix(bubbles, delayed(sweep(520, 900, 0.07) * env(int(0.07 * SR), 0.005, 40), start)[: len(bubbles)])
    return normalize(mix(hiss * 0.8, bubbles * 0.35), 0.6)


def eat():
    out = np.zeros(int(0.42 * SR))
    for start in [0.0, 0.2]:
        bite = lowpass(noise(0.11), 0.25) * env(int(0.11 * SR), 0.002, 30)
        out = mix(out, delayed(bite, start)[: len(out)])
    return normalize(out, 0.7)


def drink():
    gulp = sweep(260, 170, 0.26) * env(int(0.26 * SR), 0.01, 10)
    sip = (lowpass(noise(0.16), 0.2) - lowpass(noise(0.16), 0.04)) * env(int(0.16 * SR), 0.02, 14) * 0.6
    return normalize(mix(gulp, delayed(sip, 0.06)), 0.6)


def repair():
    out = np.zeros(int(0.5 * SR))
    for start in [0.0, 0.24]:
        click = tone(1900, 0.03) * env(int(0.03 * SR), 0.001, 90)
        body = tone(330, 0.2) * env(int(0.2 * SR), 0.002, 22)
        out = mix(out, delayed(mix(click * 0.5, body), start)[: len(out)])
    return normalize(out, 0.7)


def coin():
    a = tone(1760, 0.35) * env(int(0.35 * SR), 0.002, 9)
    b = tone(2637, 0.35) * env(int(0.35 * SR), 0.002, 11) * 0.7
    return normalize(mix(a, b, delayed(tone(2093, 0.3) * env(int(0.3 * SR), 0.002, 12) * 0.6, 0.06)), 0.5)


def panel():
    whoosh = lowpass(noise(0.2), 0.05) * env(int(0.2 * SR), 0.08, 9)
    return normalize(whoosh * 0.7 + sweep(300, 500, 0.2) * env(int(0.2 * SR), 0.08, 12) * 0.2, 0.4)


def tick():
    return normalize(tone(1400, 0.03) * env(int(0.03 * SR), 0.001, 150), 0.35)


def chime():
    out = np.zeros(int(0.9 * SR))
    for start, f in [(0.0, 523.25), (0.12, 659.25), (0.24, 783.99), (0.36, 1046.5)]:
        note = (tone(f, 0.5) + tone(f * 2, 0.5) * 0.25) * env(int(0.5 * SR), 0.004, 5)
        out = mix(out, delayed(note, start)[: len(out)])
    return normalize(out, 0.6)


def bleat():
    t = t_axis(0.6)
    f = 320 + 55 * np.sin(2 * np.pi * 6.5 * t) + 90 * np.sin(np.pi * t / 0.6)
    phase = 2 * np.pi * np.cumsum(f) / SR
    voice = np.sin(phase) + 0.3 * np.sin(2 * phase) + 0.12 * np.sin(3 * phase)
    breath = lowpass(noise(0.6), 0.08) * 0.08
    shape = env(len(t), 0.06, 2.5)
    return normalize((voice + breath) * shape, 0.55)


def buzz():
    t = t_axis(0.16)
    square = np.sign(np.sin(2 * np.pi * 140 * t)) * 0.4
    return normalize(lowpass(square, 0.3) * env(len(t), 0.005, 12), 0.45)


def thunder():
    n = int(3.0 * SR)
    rumble = lowpass(RNG.uniform(-1.0, 1.0, n), 0.01) * env(n, 0.05, 1.1)
    low = tone(48, 3.0) * env(n, 0.1, 1.4) * 0.6
    return normalize(rumble * 1.4 + low, 0.8)


def door():
    creak = sweep(210, 140, 0.45) * env(int(0.45 * SR), 0.05, 4) * 0.5
    wood = (lowpass(noise(0.12), 0.2) - lowpass(noise(0.12), 0.03)) * env(int(0.12 * SR), 0.002, 30)
    return normalize(mix(creak, delayed(wood, 0.35)), 0.55)


def strike():
    ring = tone(2300, 0.35) * env(int(0.35 * SR), 0.001, 16) * 0.6 + tone(1180, 0.35) * env(int(0.35 * SR), 0.001, 9) * 0.4
    click = lowpass(noise(0.02), 0.6) * env(int(0.02 * SR), 0.001, 200)
    return normalize(mix(ring, click), 0.6)


def gather():
    out = np.zeros(int(0.3 * SR))
    for start in [0.0, 0.1, 0.19]:
        rustle = (lowpass(noise(0.07), 0.25) - lowpass(noise(0.07), 0.03)) * env(int(0.07 * SR), 0.003, 35)
        out = mix(out, delayed(rustle, start)[: len(out)])
    return normalize(out, 0.5)


SOUNDS = {
    "step": step, "plant": plant, "harvest": harvest, "water": water, "eat": eat, "drink": drink,
    "repair": repair, "coin": coin, "panel": panel, "tick": tick, "chime": chime, "bleat": bleat,
    "buzz": buzz, "thunder": thunder, "door": door, "strike": strike, "gather": gather,
}


def write(name, samples):
    wav_path = os.path.join(OUT_DIR, name + ".wav")
    ogg_path = os.path.join(OUT_DIR, name + ".ogg")
    pcm = (np.clip(samples, -1.0, 1.0) * 32767).astype("<i2")
    with wave.open(wav_path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav_path, "-c:a", "libvorbis", "-q:a", "4", ogg_path], check=True)
    os.remove(wav_path)
    return ogg_path, len(samples) / SR


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for name, make in SOUNDS.items():
        path, seconds = write(name, make())
        print("wrote %s (%.2f s)" % (path, seconds))


if __name__ == "__main__":
    main()
