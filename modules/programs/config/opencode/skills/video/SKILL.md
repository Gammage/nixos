---
name: video
description: Use for video and subtitle workflows on this machine - converting ProRes clips and yt-dlp/YouTube downloads for DaVinci Resolve, exporting to YouTube, or generating SRT subtitles for OBS streams with whisper-cpp. Triggers on "reformat videos for davinci", "export for youtube", "add subtitles to my stream", "transcribe this stream", "get an srt for this recording", "caption my obs footage", "whisper this", "no audio in resolve", "clip has no audio", "meme clip silent", "b-roll from youtube".
---

# Video workflows

Three workflows on this machine. All were previously in a file opencode never
loaded; this skill is the supported location.

| Task | Section |
|---|---|
| "make stream editable for davinci" | [Resolve conversion](#resolve-conversion) |
| Any H.264/H.265/AAC media -> editable for Resolve | [Resolve conversion](#resolve-conversion) |
| Phone ProRes clips -> smaller editable copy | [Resolve conversion](#resolve-conversion) |
| **yt-dlp / YouTube download has no audio in Resolve** | **[yt-dlp downloads](#yt-dlp-downloads)** |
| Long form (no subs) vs shorts (burned-in subs) | [Stream deliverables](#stream-deliverables-long-form-and-shorts) |
| Finished edit -> YouTube upload | [YouTube export](#youtube-export) |
| Stream recording -> subtitles (SRT) | [Subtitles for OBS streams](#subtitles-for-obs-streams) |

---

## Resolve conversion

### Critical: free edition codec limits on Linux

**Blackmagic ships a deliberately stripped decoder set in the Linux build.** Measured
on this machine against Resolve 21.1's own bundled `libavcodec.so.60`
(`/nix/store/5f3jq4d73534mfbkhl739cml1wbd6b17-davinci-resolve-21.1/libs/`):

| codec | decoder | codec | decoder |
|---|---|---|---|
| **opus** | **MISSING** | mp3 | OK |
| **aac** | **MISSING** | flac | OK |
| av1 | OK | vorbis | OK |
| h264 | OK | alac | OK |
| hevc | OK | ac3 | OK |
| prores | OK | pcm_s16le | OK |
| dnxhd | OK | pcm_s24le | OK |

Only **Opus and AAC** are absent - the patent/licensing-encumbered pair. Every
other common codec decodes.

**Re-measure before asserting anything about codecs.** Do not trust prose
(including older versions of this skill) about what Resolve can and cannot
decode. Ask the library directly:

```bash
python3 - <<'EOF'
import ctypes
lib = ctypes.CDLL("/nix/store/5f3jq4d73534mfbkhl739cml1wbd6b17-davinci-resolve-21.1/libs/libavcodec.so.60")
lib.avcodec_find_decoder_by_name.restype = ctypes.c_void_p
lib.avcodec_find_decoder_by_name.argtypes = [ctypes.c_char_p]
for n in [b"opus",b"aac",b"av1",b"h264",b"hevc",b"mp3",b"flac",b"vorbis",b"alac",b"ac3",b"pcm_s16le",b"prores",b"dnxhd"]:
    print(n.decode(), "OK" if lib.avcodec_find_decoder_by_name(n) else "MISSING")
EOF
```

Resolve's path changes when the nixpkgs hash changes; re-run `ls -d
/nix/store/*davinci-resolve-21*` if it errors.

**Symptom of a missing decoder:** the clip imports, an audio track appears on the
timeline, and the waveform is flat. Video plays fine. **No error dialog.** Do not
chase GPU or driver settings - do not "fix" the source - the decoder is simply
absent from the build.

**Two separate layers, do not conflate them:**
1. *libavcodec decoder presence* - what the table above measures.
2. *Resolve's codec repository gate* - logs `Codec (avc1) not Found in Repository`
   (`~/.local/share/DaVinciResolve/logs/ResolveDebug.txt`) even where a decoder
   exists. H.264 sources from OBS/phone have hit this. Treat a repository error as
   authoritative for that clip: transcode it.

**Runtime confirmation from the log** - check this first for any silent-audio
report, it names the file and track directly:

```bash
rg -n "Failed to decode the audio samples|not Found in Repository|FolderEntry failed" \
  ~/.local/share/DaVinciResolve/logs/ResolveDebug.txt | tail -20
```

This is **Linux-specific**. Windows and macOS builds ship wider codec sets, so
guidance written for those platforms is wrong here.

Not fixable in the Nix config: `modules/programs/davinci-resolve.nix` just unpacks
Blackmagic's official archive, so the missing decoders are absent at the source.

Consequence: any source whose audio is **Opus or AAC** must be transcoded to
`pcm_s16le` before editing. That covers all yt-dlp downloads and all OBS/phone
recordings. Sources that are already ProRes/DNxHR + PCM are fine.

When the user requests to reformat or convert video clips for DaVinci Resolve,
follow these instructions:

### Trigger Phrases
- "make stream editable for davinci" / "make it editable" / "make editable"
- "convert stream for davinci" / "transcode the stream"
- "dnxhr the stream" / "prores the stream"
- "prepare stream for editing"
- "reformat videos for davinci"
- "convert clips for davinci"
- "prepare videos for editing"
- "format phone clips"
- Any similar request about making a video editable in DaVinci Resolve

### Source Files
- Location: `~/Downloads/`, `~/Videos/obs_footage/`, `~/Videos/footage/`, or a
  user-specified path. For yt-dlp downloads see [yt-dlp downloads](#yt-dlp-downloads).
- Format: check with `ffprobe`, never assume from the extension. Needs converting:
  - anything with **Opus or AAC** audio (all yt-dlp downloads, OBS MP4s)
  - anything the log reports `not Found in Repository` for
  - Phone ProRes HQ `.mov` - decodes fine, but enormous; convert to shrink
- Already fine, no conversion needed:
  - ProRes or DNxHR + `pcm_s16le`/PCM audio (e.g. `~/Videos/footage/channel_update_vid_edit.mov`)
  - `.mp3` audio (mp3 decoder present)
  - AV1 video + PCM audio
- Note the user may ask for subtitles *and* an editable copy. These are separate
  deliverables: the SRT is already complete and needs no re-encoding, but the video
  still needs transcoding to become editable. Never treat one as implying the other.

### Conversion Settings
- **Output codec**: ProRes **LT** (profile 1) as the editing-master default since
  2026-10-08. Rationale: output is YouTube-only (re-encodes on upload anyway), and
  the source ceiling is OBS CRF14 H.264 (~37 Mbps), so LT (~102-109 Mbps) ≈ 2.8x
  the source holds text detail without softening. Proxy (the old default) was too
  lean on text edges; 422/HQ only waste disk on a YouTube pipeline. Go up to 422
  only if a specific clip still looks soft on text at 100% zoom in Resolve.
- **Output format**: `.mov` container
- **Audio**: PCM 16-bit signed little-endian (`pcm_s16le`)
- **Sample rate**: Preserve original (typically 48000 Hz)
- **Channels**: Preserve original (typically 2ch stereo)

### FFmpeg Command Templates

**Default - ProRes LT, THREE passes** (never single-pass - see the truncation bug below).
Measured on this machine (Ryzen 7 5800X, 1080p30 CRF14 source): **~1.06x realtime**
on the video pass at ~109 Mbps, so a 4h stream takes ~3.8 h to encode and lands
**~184 GB** (vs ~265 GB for 422, ~400 GB for HQ - overkill on a YouTube-only
pipeline since YouTube re-encodes on upload anyway). Proxy (~45 Mbps, ~81 GB/4h)
was the default until 2026-10-08 but is too lean to hold text-edge detail.

**NEVER combine video and audio in a single ffmpeg command.** A single-pass
`ffmpeg -i IN -c:v prores_ks -c:a pcm_s16le OUT.mov` **silently truncates the audio
track** on long sources. See "Audio truncation bug" below - this is the single most
important rule in this skill.

```bash
# Pass 1: video only (the slow part)
ffmpeg -y -i INPUT -map 0:v:0 -c:v prores_ks -profile:v 1 -pix_fmt yuv422p10le /tmp/_v.mov

# Pass 2: audio only, to WAV (seconds, not minutes)
ffmpeg -y -i INPUT -map 0:a:0 -c:a pcm_s16le /tmp/_a.wav

# Pass 3: mux without re-encoding (-c copy, so nothing is re-processed)
ffmpeg -y -i /tmp/_v.mov -i /tmp/_a.wav -c copy -map 0:v:0 -map 1:a:0 OUTPUT.mov
```

Verified correct on this machine: 1200 s source -> video 1200.000, audio 1200.000,
230400000 audio bytes (exactly 1200 x 48000 x 2ch x 2bytes).

#### Audio truncation bug (cost two 21 GB/34 GB masters)

**Symptom:** video complete, audio stops partway. Exits 0, zero errors, `moov`
present, `ffmpeg -f null` decode silent.

| Stream | video | audio | audio bytes |
|---|---|---|---|
| 10-02 master | 2:39:02 OK | **0:42:16** truncated | 487 MB of 1832 MB |
| 10-01 master | 3:53:08 OK | **0:47:39** truncated | - |
| both sources | full OK | **full OK** | 1832087552 (complete) |

**Cause:** ffmpeg 9.0.1 stops feeding the audio encoder on long single-pass jobs and
**reports nothing**. The AAC decoder has no threading, so it cannot keep up with the
ProRes encoder consuming the stream. Reproduced deterministically: a 3000 s
single-pass run produced video 3000.000 / audio 2621.248 - 378 s short.

**Why it survived earlier verification:** `ffmpeg -v error -f null` only proves there
were no *decode errors*. Silence and truncation produce zero errors. Duration was
also only ever checked on the **video** stream. Both checks must change - see
"Verification" below.

**Consequence:** every master made before this fix is suspect. Do not trust any
single-pass ProRes/DNxHR master built here.

```bash
# NEVER use these
ffmpeg -i IN -c:v prores_ks -profile:v 1 -c:a pcm_s16le OUT.mov     # WRONG
ffmpeg -i IN -c:v dnxhd -profile:v dnxhr_lb -c:a pcm_s16le OUT.mov  # WRONG
```

**DNxHR LB - fallback only, NOT the default.** It is roughly 6x faster and the
same size, but it **crashed on a real 4h stream**: after ~3h13m at 25x it aborted
with `Assertion s->buf_ptr < s->buf_end failed at libavcodec/put_bits.h:160`,
leaving a 28 GB file with no `moov` atom - completely unplayable. A 60-second
benchmark did not surface this. Use it only for short clips (<10 min), never as
the documented default.

```bash
ffmpeg -y -i INPUT -map 0:v:0 -c:v dnxhd -profile:v dnxhr_lb -pix_fmt yuv422p10le /tmp/_v.mov
# then the same audio + mux passes as the ProRes LT template
```

**ProRes 422** - escalation only, when a specific clip is still soft on text at 100%
zoom in Resolve. ~1.4x LT (~264 GB for a 4h stream). Three passes only, as above.

```bash
# pass 1: -c:v prores_ks -profile:v 2 -pix_fmt yuv422p10le  -> /tmp/_v.mov
# pass 2: -c:a pcm_s16le -> /tmp/_a.wav   pass 3: -c copy mux -> OUTPUT.mov
```

- `-pix_fmt yuv422p10le` - required; ProRes 422 needs 4:2:2 chroma. Most phone and
  OBS sources are `yuv420p`, so this is a real conversion, not a passthrough.
- `-c:a pcm_s16le` - PCM audio. AAC will not decode in free Resolve on Linux.
- ProRes profiles: 0=proxy, 1=LT, 2=422, 3=HQ, 4/5=4444 variants

### Long transcodes
A 4h stream is a 10+ minute job. Launch it detached or the shell tool will kill the
process group on timeout:

```bash
setsid nohup bash -c '
SRC=INPUT
ffmpeg -y -v error -i "$SRC" -map 0:v:0 -c:v prores_ks -profile:v 1 \
  -pix_fmt yuv422p10le /tmp/_v.mov
ffmpeg -y -v error -i "$SRC" -map 0:a:0 -c:a pcm_s16le /tmp/_a.wav
ffmpeg -y -v error -i /tmp/_v.mov -i /tmp/_a.wav -c copy \
  -map 0:v:0 -map 1:a:0 OUTPUT.mov
rm -f /tmp/_v.mov /tmp/_a.wav
echo BUILD_DONE
' > /tmp/opencode/transcode.log 2>&1 < /dev/null &
disown
```

Build to a temp/`_NEW` name and rename after verification. Never overwrite the only
copy before the new file has passed its checks - if a transcode dies halfway, an
overwrite leaves nothing at all.

Verify it survived with `pgrep -af prores_ks`, then run the **full verification**
below. A silent decode is NOT sufficient - that check passed on both broken masters.

### Verification (mandatory, every transcode)

Run **all** of these. A transcode is not done until audio duration matches video
duration. Report actual numbers, never just "OK".

```bash
# 1. Per-stream duration, compared separately. THE check that catches truncation.
ffprobe -v error -select_streams v:0 -show_entries stream=duration -of csv=p=0 OUT.mov
ffprobe -v error -select_streams a:0 -show_entries stream=duration -of csv=p=0 OUT.mov
#    Both must match the source within ~1s. Audio shorter than video = TRUNCATED.

# 2. Audio byte count proves samples exist end to end, not just at the start.
ffmpeg -v error -i OUT.mov -map 0:a -f s16le - 2>/dev/null | wc -c
#    Expected = duration * 48000 * 2ch * 2bytes. (10-02: 9542s -> ~1832087552)

# 3. Decode an audio probe PAST the expected end (catches truncation directly).
ffmpeg -v error -ss <last_60s_before_end> -i OUT.mov -map 0:a -t 5 -f s16le - 2>/dev/null | wc -c
#    Must be non-zero. Returns 0 bytes on a truncated master.

# 4. Video decode clean + moov present
ffprobe -v error -show_entries format=duration -of csv=p=0 OUT.mov
ffmpeg -v error -i OUT.mov -f null - 2>&1 | head   # silent = no decode errors
```

**A silent decode proves only that nothing errored.** Truncated audio, all-silent
audio, and a 20 ms file all decode silently. Never report a transcode complete on
that alone.

### Destination
- Move converted deliverables to: `~/Videos/`
- For large stream working copies (multi-GB, not deliverables), use
  `~/Videos/obs_footage/edit/` so they sit next to the source and its SRT
- Suffix editable working copies with `_edit`, e.g. `<STREAM>_edit.mov`
- If a file with the same name exists, ask the user before overwriting

### Workflow
1. Identify source files in `~/Downloads/`, `~/Videos/obs_footage/`, or a
   user-specified path. Check codecs with `ffprobe` rather than assuming from the
   file extension.
2. Record source per-stream durations first - you need them to verify against.
3. Convert using the **two-pass** template above. Never single-pass.
4. Run **every** check in "Verification" and report the real numbers.
5. Report completion with file size and location.
6. Never delete or overwrite the original source without asking.

### Notes
- `-pix_fmt yuv422p10le` - use the 10-bit form. ffmpeg auto-selects it for
  `prores_ks` and warns on the bare `yuv422p`.
- `-map 0:v:0` / `-map 0:a:0` - explicit stream mapping in every pass. Prevents
  ffmpeg picking up unexpected streams.
- ProRes HQ phone footage *is* decodable by free Resolve on Linux - the conversion
  there is purely to cut file size.
- Only Opus and AAC audio are undecodable; see the decoder table at the top of
  this section. Re-measure it rather than trusting this sentence.
- Do not trust cross-platform advice about what free Resolve can play.
- Subtitle workflows are unaffected by any of this. An SRT is just a text file and
  needs no video transcoding to exist, import, or be styled.
- Prefer `~/.opencode/scripts/verify_master.sh OUT.mov SOURCE` over hand-running
  the checks. It runs every one and exits non-zero on failure.

---

## yt-dlp downloads

Short clips pulled from YouTube with `yt-dlp` land in `~/Videos/footage/` (b-roll,
memes, `b-roll/memes/`). **These are the single most likely thing to hit "no audio in
Resolve",** because yt-dlp's default output is exactly the codec pair Resolve lacks.

### Why the audio is missing

`yt-dlp` 2026.08.19 with no `~/.config/yt-dlp/config` (none exists) defaults to
**AV1 video + Opus audio in a `.webm`** container. Resolve's bundled libavcodec has
**no Opus decoder**, so:

- video imports and plays (AV1 decoder present)
- audio track appears on the timeline with a **flat waveform**
- no error dialog, no warning in the UI
- `ResolveDebug.txt` shows nothing for the file unless the media pool also failed

**Do not assume the download is broken.** Confirm the audio is really there before
blaming yt-dlp:

```bash
SRC="path/to/clip.webm"
ffprobe -v error -show_entries stream=codec_name,codec_type,sample_rate,channels \
  -of default=nw=1 "$SRC"
# bytes decoded vs expected proves samples exist end to end:
ffmpeg -v error -i "$SRC" -map 0:a -f s16le - 2>/dev/null | wc -c
# expected = duration * 48000 * 2ch * 2bytes
# per-second levels prove it is not silence:
ffmpeg -v error -i "$SRC" -map 0:a \
  -af "asetnsamples=n=48000,astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.RMS_level:file=-" \
  -f null - 2>/dev/null | head
```

Worked example, `footage/b-roll/memes/That is One Big Pile of Shit [nnun8y7r8_U].webm`:
AV1 854x480 + Opus 48k stereo, 9.009 s, 1,725,336 audio bytes decoded vs 1,729,728
expected, RMS -42 to -62 dB across all 9 s. Audio present and complete - purely a
Resolve decoder gap.

### The fix

No `yt-dlp` flag solves this: `--audio-format wav` decodes via ffmpeg but drops the
video and leaves you re-syncing by hand, and `-f "bestaudio[acodec^=mp4a]"` just
swaps Opus for AAC, which is *also* missing. **Transcode to PCM.**

Follow [Resolve conversion](#resolve-conversion) - same ProRes LT + `pcm_s16le`
settings and the same mandatory three passes:

```bash
SRC="/path/to/clip.webm"
OUT="$(dirname "$SRC")/$(basename "${SRC%.*}")_edit.mov"

ffmpeg -y -v error -i "$SRC" -map 0:v:0 -c:v prores_ks -profile:v 1 \
  -pix_fmt yuv422p10le /tmp/_v.mov
ffmpeg -y -v error -i "$SRC" -map 0:a:0 -c:a pcm_s16le /tmp/_a.wav
ffmpeg -y -v error -i /tmp/_v.mov -i /tmp/_a.wav -c copy \
  -map 0:v:0 -map 1:a:0 "$OUT"
rm -f /tmp/_v.mov /tmp/_a.wav

~/.opencode/scripts/verify_master.sh "$OUT" "$SRC"
```

Never single-pass these - the audio-truncation bug in
[Resolve conversion](#resolve-conversion) applies to any source.

### Destination

**Write the `_edit.mov` into the same directory as the source**, not `~/Videos/`.
These are short b-roll clips that belong in their themed folder
(`b-roll/memes/`, `a-roll/`, `audio/`) next to their siblings, and the user groups
them by hand. Keep the original `.webm`/`.mkv` - it is the download of record.

### Notes

- Short clips finish in seconds; run them in the foreground, no `setsid` needed.
- `verify_master.sh` compares against the **source**, and WebM/Matroska report
  per-stream duration as `N/A` (duration lives at container level). The script falls
  back to `format=duration`; if you see
  `FAIL: ... differs from source by 9.009s`, that is the fallback failing, not a
  bad master. Confirm with the per-stream durations of `OUT` and the byte count.
- Opus frame boundaries mean audio duration lands a few ms under video
  (9.009 vs 8.986 on the example above). A gap under ~1 s is correct; over 1 s is
  truncation.
- Known silent file: `footage/audio/remember who you are "Bok." [56I6VP64ko8].mkv`
  (h264 + opus, 4.921 s). Converted only if asked - the user had not requested it
  as of 2026-10-05.
- `footage/audio/*.mp3` needs no conversion (mp3 decoder present).
- After converting, the new `.mov` is a **different media ID** in the Media Pool.
  Tell the user to relink the timeline clip rather than just re-importing.

---

## Stream deliverables: long form and shorts

The user edits in DaVinci Resolve. This section defines what to hand them and how
subtitles apply to each output.

### The three artifacts

One source stream produces three independent files. **Nothing is baked into
anything else.**

```
~/Videos/obs_footage/<STREAM>.mp4                     source - never modified
~/Videos/obs_footage/edit/<STREAM>_prores.mov         editable master - NO subs
~/Videos/obs_footage/subtitles/<STREAM>.srt           full soft subtitle track
```

The master must **never** have subtitles burned in. Doing so would ruin the long
form and remove the user's choice. Subtitles are applied per-render, at export.

| Output | Subs | How |
|---|---|---|
| **Long form** | none | Deliver → Subtitle Settings → leave *Export Subtitle* **unticked** |
| **Shorts** | burned in | Deliver → Subtitle Settings → tick *Export Subtitle* → **Burn into video** |

Both come from the **same timeline, same master**. The only difference is one
checkbox at render time, so the user never needs a duplicate project.

### Burning subtitles into shorts

This is a **render setting, not an import setting**:

1. Media Pool → import `<STREAM>_prores.mov` → drag to timeline at **`00:00:00:00`**
2. Media Pool → right-click `<STREAM>.srt` → **Import Subtitle**
3. Style the track: Inspector → **Track** tab (font, size, colour, position, stroke)
4. Cut the short in the Edit page; **Mark In/Out** around it
5. **Deliver** page → **Video** tab → scroll to **Subtitle Settings**
6. Tick **Export Subtitle**, dropdown → **Burn into video**
7. Render (marked range only)

Alternative in the same panel: **Export as SRT File** instead. That uploads a soft
subtitle track rather than burning text in. Burned-in is the safe default for
autoplay/muted viewing; soft lets the user fix a typo without re-rendering.

### CRITICAL: cut shorts on the full-length timeline

The SRT is timed against the **full stream clock**. If the user copies a clip into
a new timeline to make a short, that timeline starts at `00:00:00:00` while the cues
are stamped at their original position (e.g. `01:12:03`). Result: **subtitles
missing or badly misplaced.**

Correct approach: keep cutting on the full-length master timeline so the stream
clock is preserved, then Mark In/Out and render just that range. Cues stay aligned
automatically because the timeline *is* the stream's clock.

Only copy a clip into a separate timeline if the user also re-times the cues by hand.

### Slicing the SRT without re-running whisper

Because the SRT covers the whole stream, the user does **not** need a separate
whisper run per short. Search the SRT text to find a moment, then cut that range
in Resolve. If they ever do need a trimmed SRT as a standalone file, cut on the
stream clock (same rule as above) and export from Resolve.

---

## YouTube export

When the user has finished editing in DaVinci and wants to prepare videos for
YouTube upload, follow these instructions:

### Trigger Phrases
- "export for youtube"
- "prepare for youtube upload"
- "convert for youtube"
- "ready for youtube"
- Any similar request about converting edited videos for YouTube

### Source Files
- Location: `~/Videos/` or `~/Videos/obs_footage/edit/`
- Format: `.mov` files - **ProRes LT (default), ProRes 422, or DNxHR LB**. Do not
  assume ProRes 422 specifically; the editable master defaults to ProRes LT.

### Conversion Settings
- **Output codec**: H.264 (MP4 container) - universally accepted by YouTube
- **Output format**: `.mp4`
- **Audio**: AAC at 256 kbps
- **CRF**: 18 (high quality, YouTube will re-encode anyway)
- **Preset**: slow (better compression)

### FFmpeg Command Template
```bash
ffmpeg -i INPUT.mov -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p -movflags +faststart -c:a aac -b:a 256k OUTPUT.mp4
```

- `-c:v libx264` - H.264 encoder
- `-crf 18` - Constant Rate Factor (lower = better quality, 18 is visually lossless)
- `-preset slow` - Better compression efficiency
- `-pix_fmt yuv420p` - Force 4:2:0 chroma subsampling for maximum compatibility (ProRes uses 4:2:2 which some platforms reject)
- `-movflags +faststart` - Move metadata to front of file for faster web streaming and processing
- `-c:a aac -b:a 256k` - AAC audio at 256 kbps

### Destination
- Move converted files to: `~/Videos/`
- Append `_youtube` to filename (e.g., `20260712_135905_youtube.mp4`)
- If a file with the same name exists, ask the user before overwriting

### Subtitle handling on export

ffmpeg burn-in is **not** recommended here - the SRT is timed to the full stream
clock, so on a trimmed clip the cues land in the wrong place or nowhere at all.
The user burns subtitles in **Resolve**, at render time, using Deliver → Video tab
→ Subtitle Settings → Export Subtitle → Burn into video. See
[Stream deliverables](#stream-deliverables-long-form-and-shorts).

This YouTube export step is for **clean video without subtitles** - the long form
case. For shorts with burned-in subs, export from Resolve instead.

### Cleanup
- **Never delete the editable master automatically.** A 4h ProRes LT master is
  ~184 GB and is the only Resolve-editable copy; the user may still need it for
  further cuts. Delete only with explicit confirmation, and note it is rebuilt
  from the recording source afterward - the source on `/mnt/media` outranks it.
- Never delete the original source MP4 or anything on `/mnt/media`, ever.
- Always ask before deleting anything, and report space freed if confirmed.

### Workflow
1. Identify source `.mov` files in `~/Videos/` or `~/Videos/obs_footage/edit/`
2. Convert each using the FFmpeg command above (no subtitles - see above)
3. Save converted `.mp4` to `~/Videos/` with `_youtube` suffix
4. Report the output and confirm the master is still in place
5. Delete nothing without explicit confirmation

---

## Subtitles for OBS streams

When the user wants subtitles/captions for a stream recording, especially for a
free-edition Resolve user who has no built-in AI transcription.

### Trigger Phrases
- "add subtitles to my stream"
- "transcribe this stream"
- "get an srt for this recording"
- "caption my obs footage"
- "whisper this"
- Any request to produce timed text from a video/audio file

### Critical Context: Free Resolve Edition
The user is on the **DaVinci Resolve FREE edition** (21.1). Do not suggest
purchasing Studio. This workflow is the supported substitute for the Studio-only
`Timeline > Create Subtitles from Audio` feature.

Free edition DOES support, verified in 21.1:
- Add Subtitle Track, import SRT, edit/retime cues, style in Inspector
- Burn into video (Deliver page), and export SRT/VTT/TTML sidecar

Free edition does NOT have: AI speech-to-text, text-based editing, or ASS
styling preservation (irrelevant, we style in Inspector anyway).

Never claim subtitles are unavailable in free Resolve. They are not. Only the
*generation* step is gated.

### Setup (already done, verify before assuming)
- Package: `whisper-cpp` with `vulkanSupport = true`, configured in
  `modules/programs/whisper.nix` (flake module `flake.modules.homeManager.whisper`)
- GPU: AMD Radeon RX 6700 XT (RADV NAVI22) - Vulkan backend confirmed working
- Model: `~/whisper/ggml-large-v3-turbo-q5_0.bin` (547 MB, already downloaded)
- Output SRT size: ~20.7 bytes per second of audio (4 hours ~ 291 KB, trivial)
- Throughput on this GPU: **~15x realtime**, measured end-to-end on a real 4h stream.
  Reference run (2026-10-01_17-26-29.mp4, 13,988 s audio): **942 s total (15.7 min),
  14.9x realtime**, 612 encode runs at 292 ms each, producing a 440 KB / 6,060-block
  SRT. Roughly 11x faster than CPU-only (`-ng` comparison measured 18694 ms vs
  1679 ms per 30s window).

### The miniaudio / FFmpeg trap (IMPORTANT)
`whisper-cli` tries **miniaudio first**, which can return `MA_SUCCESS` while
decoding only ~20 ms of audio. Its FFmpeg fallback then never runs, and whisper
**exits 0 while writing an empty SRT**. See `examples/common-whisper.cpp`:
`ma_decoder_init_file` returning success sets `decoder.initialized = true`,
so the `if (!decoder.initialized)` ffmpeg block is skipped.

Observed on ProRes/PCM `.mov` and some stream-copy `.mkv`. AAC-in-MP4 streams
decode fine via miniaudio. Treat the behaviour as unpredictable, not
format-specific - the same file has both worked and failed across runs.

`WHISPER_COMMON_MINIAUDIO_SKIP=1` forces the FFmpeg path. It is set globally in
`modules/programs/whisper.nix` via `home.sessionVariables`, and sourced from
`modules/programs/config/bash/.bashrc`.

**Consequence: always verify output is non-empty.** whisper exit code 0 does NOT
mean success. A missing output directory also produces only a *soft* failure -
whisper transcribes the entire file, then logs `.open: failed to open ... for
writing`, and still exits `0`. So the run looks successful while producing
nothing. Verified empirically, not inferred.

Because of that:
- `mkdir -p` the output directory first, always. It is idempotent and costs
  nothing; omitting it can throw away a full 15-minute run.
- `test -s` the SRT before reporting success. Do not trust the exit code.

### Backgrounding long runs: use `setsid`, not `nohup`
Any whisper run over a couple of minutes must be fully detached:

```bash
# WRONG - dies when the opencode shell tool times out and kills its process group
nohup whisper-cli ... > log 2>&1 &

# RIGHT - new session/process group, survives the tool's timeout
setsid nohup whisper-cli ... > log 2>&1 < /dev/null &
```

Observed failure: a 4h run launched with plain `nohup` was killed at 5% progress
(~00:21:37) when the shell tool hit its 120 s timeout. No error, no crash log -
the process simply stopped. `nohup` only ignores `SIGHUP`; it does nothing
against a process-group kill. Re-running under `setsid` completed fine.

Poll with `pgrep -x whisper-cli` plus a `progress =` grep on the log rather than
blocking the tool call.

### Command
```bash
mkdir -p ~/Videos/obs_footage/subtitles

# WHISPER_COMMON_MINIAUDIO_SKIP is set in home.sessionVariables, but non-interactive
# shells do not source it - set it explicitly on the command line.
WHISPER_COMMON_MINIAUDIO_SKIP=1 whisper-cli -m ~/whisper/ggml-large-v3-turbo-q5_0.bin \
  -f ~/Videos/obs_footage/<STREAM>.mp4 \
  -osrt -sns -t 8 -pp \
  -of ~/Videos/obs_footage/subtitles/<STREAM>

# MANDATORY verification - exit code 0 is not proof of success
test -s ~/Videos/obs_footage/subtitles/<STREAM>.srt && echo OK
```

Flag meanings:
- `-osrt` write SRT (Resolve's expected format; whisper emits `%02d:%02d:%02d,%03d`, standard comma decimals)
- `-sns` suppress non-speech tokens - strips literal `[MUSIC]` / `[BLANK_AUDIO]` text
  from cues. **Always use this** for published captions.
- `-t 8` threads (16 logical cores; 8 was fastest in A/B testing)
- `-pp` progress output. Use for long files - a 4-hour run is ~15-20 min of silence
  otherwise.

### Known Quality Characteristics (warn the user)
- **Long unwrapped cues.** whisper writes one cue per segment, up to ~30 s, with no
  line breaks. Fine for Resolve, but reads lopsided as captions. If the user wants
  short punchy social-style cues, re-run with `-sow` (split on word) plus
  `-ml 42` (max chars/line). Don't apply preemptively - it costs a full re-run, so
  let the user judge from a real sample first.
- **Hallucinations in silence.** Whisper invents plausible text during long quiet
  stretches and produces repeated phrases. The user should skim the SRT against the
  video before trusting it. For heavily-silent audio, VAD helps:
  `--vad -vm <silero-model>` (model not yet downloaded; one-time ~1 MB fetch).
  Not needed for continuous talking-head speech.
- Timing accuracy is good (~+/-1 s) and timestamps are absolute against the source
  file, which is what makes the Resolve workflow below work.

### DaVinci Resolve 21.1 Import Steps
1. Media Pool -> import the source `.mp4` -> drag to timeline at **`00:00:00:00`**
2. Media Pool -> right-click -> **Import Subtitle** -> select the `.srt`
   (also available: `File > Import > Timeline > Subtitle` in some versions)
3. Drag the imported subtitle clip onto a subtitle track
4. Check first / middle / last cues before styling

**Alignment gotcha:** if cues land offset, the timeline usually didn't start at
`00:00:00:00`, or the SRT was dropped onto a clip instead of the track. Fix with
right-click -> **Insert Selected Subtitles to Timeline Using Timecode**.

Keep subtitles as a **soft track** during editing - fully removable, retimeable,
restylable, and the video file is untouched. Only enable **Deliver -> Subtitles ->
Burn into video** for final exported Shorts, never on the source or intermediates.
Burned-in text is rasterised into the pixels and cannot be undone without re-render.

### Workflow
1. Confirm source file and that the model exists at `~/whisper/`
2. `mkdir -p` the subtitles output dir
3. Run `whisper-cli` with `-osrt -sns -t 8 -pp`
4. **Verify with `test -s`** and report the SRT size + block count
5. Spot-check a few cues for hallucinations; report any concerns
6. Tell the user the Resolve import path and the soft-vs-burned-in distinction
7. Log the run duration so throughput expectations stay calibrated