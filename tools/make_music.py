"""Renders the game's placeholder music: one short track for each entry in MusicSystem.TRACKS
(scripts/music_system.gd), written to audio/music/<id>.ogg, and the old dreary loop.

Everything is synthesized here, so the music is original and reproducible (each track has its own seed).
They are stand-ins until the commissioned tracks in MUSIC_BRIEF.md arrive: each has its own key, tempo,
instruments and mood, so the music director can be heard and tested. Loops are a whole number of bars, and
notes and filters that run past the end wrap to the start, so they loop without a seam.

Run it from the project folder (needs numpy and ffmpeg):
    python tools/make_music.py            all the placeholder tracks
    python tools/make_music.py night cave just these
    python tools/make_music.py dreary     the old loop, audio/dreary_loop.ogg (the fallback for a missing track)
Then import them once: godot --path . --headless --import
"""
import os
import subprocess
import sys
import wave

import numpy as np

SR = 32000

MODES = {
    "major": [0, 2, 4, 5, 7, 9, 11],
    "minor": [0, 2, 3, 5, 7, 8, 10],
    "dorian": [0, 2, 3, 5, 7, 9, 10],
    "mixolydian": [0, 2, 4, 5, 7, 9, 10],
    "lydian": [0, 2, 4, 6, 7, 9, 11],
    "phrygian": [0, 1, 3, 5, 7, 8, 10],
}


def midi_hz(m):
    return 440.0 * 2.0 ** ((m - 69) / 12.0)


class Loop:
    """A buffer a whole number of bars long. Anything added past the end wraps to the start."""

    def __init__(self, seconds, wrap=True):
        self.n = int(seconds * SR)
        self.wrap = wrap
        self.buf = np.zeros(self.n)

    def add(self, start_s, sig):
        i0 = int(start_s * SR)
        if self.wrap:
            idx = (np.arange(len(sig)) + i0 % self.n) % self.n
            np.add.at(self.buf, idx, sig)
        else:
            sig = sig[: max(0, self.n - i0)]
            self.buf[i0 : i0 + len(sig)] += sig


def times(dur):
    return np.arange(int(dur * SR)) / SR


def tone(freq, dur, decay, attack=0.005, harmonics=(1.0, 0.25, 0.08)):
    t = times(dur)
    sig = np.zeros_like(t)
    for k, amp in enumerate(harmonics, start=1):
        sig += amp * np.sin(2 * np.pi * freq * k * t)
    env = np.exp(-t * decay)
    env *= np.minimum(1.0, t / attack) if attack > 0 else 1.0
    return sig * env


def pad(freq, dur):
    t = times(dur)
    env = np.minimum(1.0, t / 0.6) * np.minimum(1.0, (dur - t) / 0.8).clip(0, 1)
    sig = np.sin(2 * np.pi * freq * t) + 0.6 * (2 * np.abs(2 * ((freq * t) % 1) - 1) - 1)
    return sig * env * 0.5


# The voices. Each takes a frequency and a length, and returns a mono signal.
def v_keys(f, d):        # a soft electric piano
    return tone(f, d + 0.9, 3.2)


def v_pluck(f, d):       # a nylon guitar or banjo: bright, quick decay
    return tone(f, d + 0.6, 5.0, 0.002, (1.0, 0.5, 0.33, 0.2, 0.1))


def v_bell(f, d):        # a music box or celesta: inharmonic partials
    t = times(d + 1.6)
    sig = np.sin(2 * np.pi * f * t) + 0.4 * np.sin(2 * np.pi * f * 2.76 * t) * np.exp(-t * 4) \
        + 0.2 * np.sin(2 * np.pi * f * 5.4 * t) * np.exp(-t * 8)
    return sig * np.exp(-t * 2.2) * np.minimum(1.0, t / 0.002)


def v_bowed(f, d):       # a fiddle or cello: a slow swell with vibrato
    t = times(d + 0.3)
    ph = 2 * np.pi * np.cumsum(f * (1 + 0.006 * np.sin(2 * np.pi * 5.2 * t))) / SR
    sig = sum(np.sin(k * ph) / k for k in range(1, 7))
    env = np.minimum(1.0, t / 0.25) * np.minimum(1.0, (d + 0.3 - t) / 0.3).clip(0, 1)
    return sig * env * 0.6


def v_flute(f, d):        # a wooden flute: breathy
    t = times(d + 0.2)
    rng = np.random.default_rng(int(f * 10))
    ph = 2 * np.pi * np.cumsum(f * (1 + 0.004 * np.sin(2 * np.pi * 4.5 * t))) / SR
    breath = np.convolve(rng.standard_normal(len(t)), np.ones(6) / 6, mode="same") * 0.08
    env = np.minimum(1.0, t / 0.12) * np.minimum(1.0, (d + 0.2 - t) / 0.2).clip(0, 1)
    return (np.sin(ph) + 0.15 * np.sin(2 * ph) + breath) * env * 0.7


def v_organ(f, d):       # a pump organ or harmonium
    t = times(d)
    sig = np.sin(2 * np.pi * f * t) + 0.5 * np.sin(4 * np.pi * f * t) + 0.25 * np.sin(6 * np.pi * f * t)
    env = np.minimum(1.0, t / 0.4) * np.minimum(1.0, (d - t) / 0.5).clip(0, 1)
    return sig * env * 0.4


def v_drone(f, d):       # a low bowed drone, slowly beating against itself
    t = times(d)
    sig = sum(np.sin(2 * np.pi * f * k * (1 + det) * t) / k for k in (1, 2, 3) for det in (0.0, 0.003))
    env = np.minimum(1.0, t / 1.5) * np.minimum(1.0, (d - t) / 1.5).clip(0, 1)
    return sig * env * 0.3


VOICES = {"keys": v_keys, "pluck": v_pluck, "bell": v_bell, "bowed": v_bowed, "flute": v_flute,
          "organ": v_organ, "drone": v_drone, "pad": lambda f, d: pad(f, d)}


def kick(loop, start, rng, amp=0.9):
    t = times(0.35)
    f = 42 + 70 * np.exp(-t * 28)
    loop.add(start, np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 11) * amp)


def snare(loop, start, rng, amp=0.22):
    t = times(0.22)
    loop.add(start, np.diff(rng.standard_normal(len(t)), prepend=0.0) * np.exp(-t * 22) * amp)


def hat(loop, start, rng, amp=0.05):
    t = times(0.05)
    loop.add(start, np.diff(rng.standard_normal(len(t)), prepend=0.0) * np.exp(-t * 90) * amp)


def heart(loop, start, rng):
    kick(loop, start, rng, 0.8)
    kick(loop, start + 0.22, rng, 0.5)


def lowpass(x, width, wrap=True):
    if width <= 1:
        return x
    if wrap:
        x = np.concatenate([x[-width:], x, x[:width]])
        return np.convolve(x, np.ones(width) / width, mode="same")[width:-width]
    return np.convolve(x, np.ones(width) / width, mode="same")


def texture(kind, n, rng):
    """The room's sound under the music: tape hiss, rain, wind or vinyl crackle. Built to loop."""
    if kind == "crackle":
        c = np.zeros(n)
        pops = rng.integers(0, n, size=int(n / SR * 26))
        c[pops] = rng.uniform(-0.5, 0.5, size=len(pops))
        return lowpass(c, 4) * 0.5
    noise = rng.standard_normal(n)
    if kind == "hiss":
        return np.diff(noise, prepend=0.0) * 0.006
    if kind == "rain":
        return lowpass(noise, 60) * 0.02
    if kind == "wind":
        swell = 0.5 + 0.5 * np.sin(2 * np.pi * np.arange(n) / n * 3)
        return lowpass(noise, 200) * swell * 0.12
    return np.zeros(n)


def write_ogg(mix, path, lufs):
    """Writes 44.1 kHz OGG Vorbis at the loudness MUSIC_BRIEF.md asks of the real tracks (-18 LUFS for loops)."""
    mix = mix / max(1e-9, np.max(np.abs(mix))) * 0.5
    wav = path[:-4] + ".wav"
    with wave.open(wav, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((mix * 32767).astype("<i2").tobytes())
    # One fixed gain to the target (a gain that moved over time would leave a seam at the loop), and a limiter for peaks.
    meter = subprocess.run(["ffmpeg", "-hide_banner", "-i", wav, "-af", "ebur128=framelog=quiet", "-f", "null", "-"],
                           capture_output=True, text=True).stderr
    measured = float(meter.rsplit("I:", 1)[1].split("LUFS")[0])
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-af", "volume=%.2fdB,alimiter=limit=0.84:level=0" % (lufs - measured),
                    "-ar", "44100", "-c:a", "libvorbis", "-q:a", "3", path], check=True)
    os.remove(wav)
    print("wrote %s, %.1f seconds" % (path, len(mix) / SR))


# The placeholder tracks. root: the key's tonic (MIDI). chords: scale degrees (0-6), one per two bars.
# lead/comp: the melody's and the accompaniment's voices. density: melody notes a bar. drums: lofi, brush,
# pulse, heart or none. tex: the room under it. filt: how muffled (a moving average's width).
TRACKS = {
    "title": dict(seed=101, bpm=58, bars=8, root=62, mode="minor", chords=[0, 5, 3, 4], lead="bell", comp="organ",
                  density=2, drums="none", tex="crackle", filt=6),
    "spring": dict(seed=102, bpm=84, bars=8, root=67, mode="mixolydian", chords=[0, 3, 6, 0], lead="flute", comp="pluck",
                   density=3, drums="brush", tex="hiss", filt=4, arp=True),
    "summer": dict(seed=103, bpm=92, bars=8, root=60, mode="lydian", chords=[0, 1, 5, 4], lead="pluck", comp="keys",
                   density=4, drums="brush", tex="hiss", filt=3, arp=True),
    "autumn": dict(seed=104, bpm=72, bars=8, root=57, mode="dorian", chords=[0, 3, 6, 4], lead="bowed", comp="keys",
                   density=2, drums="lofi", tex="rain", filt=7),
    "winter": dict(seed=105, bpm=60, bars=8, root=64, mode="minor", chords=[0, 5, 2, 6], lead="bell", comp="pad",
                   density=2, drums="none", tex="wind", filt=5),
    "hearth": dict(seed=106, bpm=66, bars=8, root=65, mode="major", chords=[0, 3, 1, 4], lead="keys", comp="pad",
                   density=1, drums="none", tex="crackle", filt=9),
    "night": dict(seed=107, bpm=54, bars=8, root=59, mode="phrygian", chords=[0, 1, 0, 6], lead="flute", comp="drone",
                  density=1, drums="none", tex="wind", filt=8),
    "trek": dict(seed=108, bpm=80, bars=8, root=61, mode="minor", chords=[0, 0, 5, 6], lead="pluck", comp="drone",
                 density=4, drums="pulse", tex="hiss", filt=4, low=True),
    "trek_tense": dict(seed=109, bpm=80, bars=8, root=61, mode="phrygian", chords=[0, 0, 1, 1], lead="bowed", comp="none",
                       density=8, drums="heart", tex="none", filt=3, tremolo=True),
    "cave": dict(seed=110, bpm=50, bars=8, root=51, mode="phrygian", chords=[0, 0, 1, 0], lead="bell", comp="drone",
                 density=1, drums="none", tex="wind", filt=10, low=True),
    "dread": dict(seed=111, bpm=46, bars=8, root=46, mode="phrygian", chords=[0, 1, 0, 1], lead="bowed", comp="drone",
                  density=1, drums="heart", tex="wind", filt=10, low=True, cluster=True),
    "hollow": dict(seed=112, bpm=40, bars=8, root=41, mode="phrygian", chords=[0, 1, 4, 1], lead="bell", comp="drone",
                   density=1, drums="heart", tex="wind", filt=12, low=True, cluster=True),
    "ending": dict(seed=113, bpm=64, bars=16, root=62, mode="dorian", chords=[0, 3, 5, 4, 0, 3, 6, 0], lead="bowed",
                   comp="keys", density=2, drums="none", tex="crackle", filt=5),
}

# The stingers: one-shots, not loops. notes: semitones above root, played in turn every `gap` seconds.
STINGS = {
    "sting_visitor": dict(seed=201, root=46, notes=[0, 1, 6], gap=0.0, voice="bowed", dur=2.6, boom=True),
    "sting_hollow": dict(seed=202, root=34, notes=[0, 1, 6, 11], gap=0.0, voice="drone", dur=4.0, boom=True),
    "sting_page": dict(seed=203, root=74, notes=[0, 3, 7, 10, 14], gap=0.16, voice="bell", dur=2.4),
    "sting_achievement": dict(seed=204, root=79, notes=[0, 4, 7, 12], gap=0.1, voice="bell", dur=1.6),
    "sting_bell": dict(seed=205, root=50, notes=[0, 0, 0], gap=1.6, voice="toll", dur=6.5),
}


def chord_of(spec, degree):
    """The triad (with a seventh) on a scale degree, as MIDI notes."""
    scale = MODES[spec["mode"]]
    notes = []
    for step in (0, 2, 4, 6):
        i = degree + step
        notes.append(spec["root"] + scale[i % 7] + 12 * (i // 7))
    if spec.get("cluster"):
        notes = [notes[0], notes[0] + 1, notes[0] + 6]   # a tritone and a semitone rub
    return notes


def render_track(name, spec):
    rng = np.random.default_rng(spec["seed"])
    beat = 60.0 / spec["bpm"]
    bar = 4 * beat
    loop = Loop(spec["bars"] * bar)
    lead, comp, drums = Loop(loop.n / SR), Loop(loop.n / SR), Loop(loop.n / SR)
    scale = MODES[spec["mode"]]
    low = -12 if spec.get("low") else 0
    for b in range(spec["bars"]):
        t0 = b * bar
        chord = chord_of(spec, spec["chords"][(b // 2) % len(spec["chords"])])
        # The accompaniment: held chords, or arpeggios for the plucked day themes.
        if spec["comp"] != "none":
            voice = VOICES[spec["comp"]]
            if spec.get("arp"):
                for i in range(8):
                    m = chord[[0, 1, 2, 1, 3, 2, 1, 2][i]] - 12
                    comp.add(t0 + i * beat / 2, voice(midi_hz(m), beat / 2) * 0.35)
            elif b % 2 == 0:
                for m in chord[:3]:
                    comp.add(t0, voice(midi_hz(m - 12 + low), bar * 2.02) * 0.4)
        # A bass on the root.
        lead_root = chord[0] - 24 + (12 if spec.get("low") else 0)
        comp.add(t0, tone(midi_hz(lead_root), bar * 0.9, 1.2, 0.02, (1.0, 0.2)) * 0.5)
        # The melody: a wandering walk over the scale, landing on chord tones.
        slots = rng.choice(16, size=min(16, spec["density"]), replace=False) / 4.0 if spec["density"] < 8 else np.arange(8) / 2.0
        for s in sorted(slots):
            deg = rng.integers(0, 8)
            m = spec["root"] + 12 + low + scale[deg % 7] + 12 * (deg // 7)
            if rng.random() < 0.5:
                m = chord[rng.integers(0, 3)] + 12 + low
            dur = beat * (0.5 if spec["density"] >= 8 else rng.choice([1.0, 1.5, 2.0]))
            sig = VOICES[spec["lead"]](midi_hz(m), dur)
            if spec.get("tremolo"):
                sig *= 0.6 + 0.4 * np.sin(2 * np.pi * 9 * times(len(sig) / SR))
            lead.add(t0 + s * beat, sig * 0.4)
        # Drums.
        kind = spec["drums"]
        for k in range(4):
            tb = t0 + k * beat
            if kind == "lofi":
                (kick if k in (0, 2) else snare)(drums, tb, rng)
                hat(drums, tb, rng)
                hat(drums, tb + beat / 2, rng)
            elif kind == "brush":
                if k == 0:
                    kick(drums, tb, rng, 0.5)
                snare(drums, tb + beat / 2, rng, 0.06)
                hat(drums, tb, rng, 0.03)
            elif kind == "pulse":
                kick(drums, tb, rng, 0.45)
            elif kind == "heart" and k in (0, 2):
                heart(drums, tb, rng)
    mix = lead.buf * 0.55 + comp.buf * 0.5 + drums.buf * 0.7 + texture(spec["tex"], loop.n, rng)
    mix = lowpass(mix, spec["filt"])
    write_ogg(mix, os.path.join("audio", "music", name + ".ogg"), -18)


def render_sting(name, spec):
    rng = np.random.default_rng(spec["seed"])
    loop = Loop(spec["dur"], wrap=False)
    for i, n in enumerate(spec["notes"]):
        f = midi_hz(spec["root"] + n)
        if spec["voice"] == "toll":
            t = times(spec["dur"] - i * spec["gap"])
            sig = sum(a * np.sin(2 * np.pi * f * r * t) * np.exp(-t * d)
                      for r, a, d in ((0.5, 0.6, 0.5), (1.0, 1.0, 0.8), (1.19, 0.5, 1.2), (2.0, 0.4, 1.5), (2.74, 0.3, 2.5)))
            sig *= np.minimum(1.0, t / 0.003)
        else:
            sig = VOICES[spec["voice"]](f, spec["dur"] - i * spec["gap"] - 1.7)
        loop.add(i * spec["gap"], sig[: loop.n] * 0.5)
    if spec.get("boom"):
        t = times(1.2)
        f = 30 + 40 * np.exp(-t * 6)
        loop.add(0.0, np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 3) * 0.9)
        loop.add(0.0, lowpass(rng.standard_normal(len(t)), 30, False) * np.exp(-t * 4) * 0.3)
    fade = np.minimum(1.0, (loop.n - np.arange(loop.n)) / (0.4 * SR))
    write_ogg(lowpass(loop.buf * fade, 4, False), os.path.join("audio", "music", name + ".ogg"), -16)


def render_dreary():
    """The old placeholder loop: 16 bars at 72 BPM, Am7 Fmaj7 Dm7 E7, lo-fi drums, rain and vinyl."""
    rng = np.random.default_rng(61019)
    beat = 60.0 / 72.0
    bar = 4 * beat
    n = int(16 * bar * SR)
    pads, keys, bass, drums = Loop(n / SR), Loop(n / SR), Loop(n / SR), Loop(n / SR)
    chords = [[57, 60, 64, 67], [53, 57, 60, 64], [50, 53, 57, 60], [52, 56, 59, 62]]
    for c_index, chord in enumerate(chords):
        for bar_in_chord in range(4):
            t0 = (c_index * 4 + bar_in_chord) * bar
            for m in chord:
                pads.add(t0, pad(midi_hz(m - 12), bar * 1.02))
            for beat_pos in (0, 2):
                bass.add(t0 + beat_pos * beat, tone(midi_hz(chord[0] - 24), 1.4 * beat, 3.0, harmonics=(1.0, 0.15)) * 0.55)
            slots = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5]
            for p in sorted(rng.choice(len(slots), size=rng.integers(2, 4), replace=False)):
                m = chord[rng.integers(len(chord))] + 12 * (1 + rng.integers(0, 2))
                dur = rng.choice([0.75, 1.0, 1.5]) * beat
                keys.add(t0 + slots[p] * beat, tone(midi_hz(m), dur + 0.9, 3.2) * 0.32)
            for beat_pos in range(4):
                tb = t0 + beat_pos * beat
                (kick if beat_pos in (0, 2) else snare)(drums, tb, rng)
                hat(drums, tb, rng)
                hat(drums, tb + beat / 2, rng)
    rain = np.convolve(rng.standard_normal(n), np.ones(60) / 60.0, mode="same") * 0.6
    mix = pads.buf * 0.35 + keys.buf * 0.5 + bass.buf * 0.7 + drums.buf * 0.8 + rain * 0.035 + texture("crackle", n, rng)
    write_ogg(lowpass(mix, 8), os.path.join("audio", "dreary_loop.ogg"), -18)


if __name__ == "__main__":
    os.makedirs(os.path.join("audio", "music"), exist_ok=True)
    wanted = sys.argv[1:] or list(TRACKS) + list(STINGS)
    for name in wanted:
        if name == "dreary":
            render_dreary()
        elif name in TRACKS:
            render_track(name, TRACKS[name])
        elif name in STINGS:
            render_sting(name, STINGS[name])
        else:
            sys.exit("no track called %s" % name)
