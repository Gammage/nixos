---
name: video
description: Use for video and subtitle workflows on this machine - converting ProRes clips for DaVinci Resolve, exporting to YouTube, or generating SRT subtitles for OBS streams with whisper-cpp. Triggers on "reformat videos for davinci", "export for youtube", "add subtitles to my stream", "transcribe this stream", "get an srt for this recording", "caption my obs footage", "whisper this".
---

# Video workflows

Three workflows on this machine. All were previously in a file opencode never
loaded; this skill is the supported location.

| Task | Section |
|---|---|
| ProRes clips -> editable for Resolve | [ProRes conversion](#prores-conversion) |
| Finished edit -> YouTube upload | [YouTube export](#youtube-export) |
| Stream recording -> subtitles (SRT) | [Subtitles for OBS streams](#subtitles-for-obs-streams) |

---

## ProRes conversion

When the user requests to reformat or convert video clips for DaVinci Resolve,
follow these instructions:

### Trigger Phrases
- "reformat videos for davinci"
- "convert clips for davinci"
- "prepare videos for editing"
- "format phone clips"
- Any similar request about converting video files for use in DaVinci Resolve

### Source Files
- Location: `~/Downloads/` or subfolders within Downloads
- Format: Phone-recorded `.mov` files (Apple ProRes HQ codec)
- These are typically large files (several GB each)

### Conversion Settings
- **Output codec**: ProRes 422 (not HQ - saves space while maintaining quality)
- **Output format**: `.mov` container
- **Audio**: PCM 16-bit signed little-endian (`pcm_s16le`)
- **Sample rate**: Preserve original (typically 48000 Hz)
- **Channels**: Preserve original (typically 2ch stereo)

### FFmpeg Command Template
```bash
ffmpeg -i INPUT.mov -c:v prores_ks -profile:v 2 -c:a pcm_s16le OUTPUT.mov
```

- `-c:v prores_ks` - Use the high-quality ProRes encoder
- `-profile:v 2` - ProRes 422 Standard profile (0=proxy, 1=LT, 2=422, 3=HQ)
- `-c:a pcm_s16le` - PCM audio matching original quality

### Destination
- Move converted files to: `~/Videos/`
- Maintain original filename (change extension from any format to `.mov`)
- If a file with the same name exists, ask the user before overwriting

### Workflow
1. Identify source `.mov` files in `~/Downloads/` or user-specified location
2. Convert each file using the FFmpeg command above
3. Move the converted file to `~/Videos/`
4. Report completion with file sizes and location

### Notes
- The original phone recordings are ProRes HQ which DaVinci accepts but files are very large
- Converting to ProRes 422 reduces file size significantly while remaining professional quality
- For YouTube clips (H.265/HEVC in MP4), use: `ffmpeg -i input.mp4 -c:v prores_ks -profile:v 2 -c:a pcm_s16le output.mov`

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
- Location: `~/Videos/` (edited ProRes files from DaVinci)
- Format: `.mov` files (ProRes 422 or ProRes HQ)

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

### Cleanup
- **Delete the source ProRes `.mov` files after successful conversion**
- ProRes files are very large (often 5-15 GB each)
- Always confirm with user before deleting
- Report space freed

### Workflow
1. Identify source `.mov` files in `~/Videos/` or user-specified location
2. Convert each file using the FFmpeg command above
3. Save converted `.mp4` to `~/Videos/` with `_youtube` suffix
4. Ask user to confirm deletion of source ProRes files
5. Delete confirmed files and report space saved

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