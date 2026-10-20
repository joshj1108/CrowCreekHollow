"""Renders the farm's dreary lo-fi loop to audio/dreary_loop.ogg.

Everything is synthesized here, so the loop is original and reproducible. Run it from the
project folder with: python3 tools/make_music.py   (needs numpy and ffmpeg).
The loop is 16 bars at 72 BPM. Notes that run past the end wrap to the start, so it loops seamlessly.
"""
import os
import subprocess
import wave

import numpy as np

SR = 32000
BPM = 72.0
BEAT = 60.0 / BPM
BAR = 4 * BEAT
BARS = 16
N = int(BARS * BAR * SR)
RNG = np.random.default_rng(61019)

buf_pad = np.zeros(N)
buf_keys = np.zeros(N)
buf_bass = np.zeros(N)
buf_drums = np.zeros(N)


def midi_hz(m):
    return 440.0 * 2.0 ** ((m - 69) / 12.0)


def add(buf, start_s, sig):
    """Adds a signal into the loop at a time, wrapping past the end."""
    i0 = int(start_s * SR) % N
    idx = (np.arange(len(sig)) + i0) % N
    np.add.at(buf, idx, sig)


def tone(freq, dur, decay, attack=0.005, harmonics=(1.0, 0.25, 0.08)):
    t = np.arange(int(dur * SR)) / SR
    sig = np.zeros_like(t)
    for k, amp in enumerate(harmonics, start=1):
        sig += amp * np.sin(2 * np.pi * freq * k * t)
    env = np.exp(-t * decay)
    env *= np.minimum(1.0, t / attack) if attack > 0 else 1.0
    return sig * env


def pad(freq, dur):
    t = np.arange(int(dur * SR)) / SR
    env = np.minimum(1.0, t / 0.6) * np.minimum(1.0, (dur - t) / 0.8).clip(0, 1)
    sig = np.sin(2 * np.pi * freq * t) + 0.6 * (2 * np.abs(2 * ((freq * t) % 1) - 1) - 1)
    return sig * env * 0.5


def kick(start):
    dur = 0.35
    t = np.arange(int(dur * SR)) / SR
    f = 42 + 70 * np.exp(-t * 28)
    phase = 2 * np.pi * np.cumsum(f) / SR
    add(buf_drums, start, np.sin(phase) * np.exp(-t * 11) * 0.9)


def snare(start):
    dur = 0.22
    t = np.arange(int(dur * SR)) / SR
    noise = RNG.standard_normal(len(t))
    noise = np.diff(noise, prepend=0.0)  # a gentle high-pass
    add(buf_drums, start, noise * np.exp(-t * 22) * 0.22)


def hat(start):
    dur = 0.05
    t = np.arange(int(dur * SR)) / SR
    noise = np.diff(RNG.standard_normal(len(t)), prepend=0.0)
    add(buf_drums, start, noise * np.exp(-t * 90) * 0.05)


# Chords: four bars each. Minor and dim colours keep it dreary.
CHORDS = [
    [57, 60, 64, 67],  # Am7
    [53, 57, 60, 64],  # Fmaj7
    [50, 53, 57, 60],  # Dm7
    [52, 56, 59, 62],  # E7 (with the 7th)
]

for c_index, chord in enumerate(CHORDS):
    start_bar = c_index * 4
    for bar_in_chord in range(4):
        b = start_bar + bar_in_chord
        t0 = b * BAR
        # Pads hold the chord through the bar.
        for m in chord:
            add(buf_pad, t0, pad(midi_hz(m - 12), BAR * 1.02))
        # A soft bass note on the root, on beats 1 and 3.
        root = chord[0] - 24
        for beat_pos in (0, 2):
            add(buf_bass, t0 + beat_pos * BEAT, tone(midi_hz(root), 1.4 * BEAT, 3.0, harmonics=(1.0, 0.15)) * 0.55)
        # Sparse keys melody: two or three chord tones per bar, on lazy off-beats.
        slots = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5]
        picks = sorted(RNG.choice(len(slots), size=RNG.integers(2, 4), replace=False))
        for p in picks:
            m = chord[RNG.integers(len(chord))] + 12 * (1 + RNG.integers(0, 2))
            dur = RNG.choice([0.75, 1.0, 1.5]) * BEAT
            add(buf_keys, t0 + slots[p] * BEAT, tone(midi_hz(m), dur + 0.9, 3.2) * 0.32)
        # Drums: a soft kick on 1 and 3, a snare on 2 and 4, and quiet hats on the eighths.
        for beat_pos in range(4):
            tb = t0 + beat_pos * BEAT
            if beat_pos in (0, 2):
                kick(tb)
            else:
                snare(tb)
            hat(tb)
            hat(tb + BEAT / 2)

# Rain and vinyl, the room's sound. Rain is low noise; the crackle is a sparse pop train.
rain = RNG.standard_normal(N)
rain = np.convolve(rain, np.ones(60) / 60.0, mode="same") * 0.6
crackle = np.zeros(N)
pops = RNG.integers(0, N, size=int(N / SR * 26))
crackle[pops] = RNG.uniform(-0.5, 0.5, size=len(pops))
crackle = np.convolve(crackle, np.exp(-np.arange(12) / 3.0), mode="same")

mix = (
    buf_pad * 0.35
    + buf_keys * 0.5
    + buf_bass * 0.7
    + buf_drums * 0.8
    + rain * 0.035
    + crackle * 0.5
)

# Muffle the whole mix for the lo-fi, rainy-window feel. A simple moving average works as a low-pass.
mix = np.convolve(np.concatenate([mix[-8:], mix, mix[:8]]), np.ones(8) / 8.0, mode="valid")[: N]
mix = mix / np.max(np.abs(mix)) * 0.8

pcm = (mix * 32767).astype("<i2")
wav_path = os.path.join("audio", "dreary_loop.wav")
with wave.open(wav_path, "wb") as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(pcm.tobytes())

subprocess.run(
    ["ffmpeg", "-y", "-loglevel", "error", "-i", wav_path, "-c:a", "libvorbis", "-q:a", "4",
     os.path.join("audio", "dreary_loop.ogg")],
    check=True,
)
os.remove(wav_path)
print("wrote audio/dreary_loop.ogg, %.1f seconds" % (N / SR))
