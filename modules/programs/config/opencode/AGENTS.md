# opencode instructions

## ADB (Android file transfer)
- Package: `pkgs.android-tools` (configured inline in `hosts/desktop/default.nix:18`)
- Usage: enable USB Debugging on phone, then `adb pull /sdcard/DCIM/Camera/ <dest>`

## Session notes / compaction
- When asked to "make a note" or "compact recent events", create an Obsidian note:
  1. `nvim -e -c "Obsidian new_from_template session-summary" -c "wq"` (run from vault root `/home/ben/notes`)
  2. Edit: add descriptive alias, fill in sections (summary, files, decisions, lessons, questions)
  3. Move to llm_notes: `mv "files/<ID>.md" "files/llm_notes/<ID>.md"`

## If working with obsidian/notes directory
- Note IDs come from obsidian.nvim's `note_id_func` (`builtin.zettel_id`):
  `os.time()` + `-` + 4 random A-Z chars. Filename and `id:` are written from the
  same call, so they always agree — nothing to enforce by hand.
- Session notes go in `files/llm_notes/`; templates in `templates/`
- Details and the session-note workflow are in the `obsidian` skill

## Project Zomboid (retired)
- No longer played. No server config in NixOS, no systemd units, no backups.
- Do not set up, run, or maintain a Zomboid server.
- Game data is mostly gone. Only `~/Zomboid/Saves/` (~3.1 GB) plus logs remain, kept
  as-is in case old worlds are ever wanted. Deletable if the user asks.

## Video subtitles (whisper-cpp → DaVinci Resolve)

User is on **DaVinci Resolve FREE (21.1)**. Do not suggest buying Studio. Free
edition fully supports adding/importing SRT, editing, styling and burning in —
only AI transcription is Studio-gated. Never claim subtitles are unavailable.

**Separate but easy to conflate:** free Resolve *on Linux* cannot decode
H.264/H.265 or AAC. Phone MP4s and OBS streams import with a black viewer and no
error dialog — they must be transcoded to DNxHR LB or ProRes + `pcm_s16le` before
editing (see the `video` skill). This never affects SRTs: they are plain text and
need no video to exist. A request for subtitles does not imply the video is already
editable, and vice versa.

Set up and working:
- Package `whisper-cpp` with `vulkanSupport = true` (`modules/programs/whisper.nix`)
- GPU RX 6700 XT (RADV), model `~/whisper/ggml-large-v3-turbo-q5_0.bin`
- Throughput **~15x realtime**: a 4h stream takes ~15-20 min

```bash
mkdir -p ~/Videos/obs_footage/subtitles
WHISPER_COMMON_MINIAUDIO_SKIP=1 whisper-cli \
  -m ~/whisper/ggml-large-v3-turbo-q5_0.bin \
  -f ~/Videos/obs_footage/<STREAM>.mp4 \
  -osrt -sns -t 8 -pp \
  -of ~/Videos/obs_footage/subtitles/<STREAM>

test -s ~/Videos/obs_footage/subtitles/<STREAM>.srt && echo OK
```

Four traps that have already cost time:
1. **Exit 0 does not mean success.** Verified empirically: whisper exits `0` both
   when it decodes ~20 ms of audio *and* when it cannot open the output file.
   Always `test -s`. `WHISPER_COMMON_MINIAUDIO_SKIP=1` forces FFmpeg instead of
   the unreliable miniaudio path.
2. **`mkdir -p` is mandatory.** whisper does not create output directories. It
   transcribes the whole file, fails to open the output, and still exits 0 —
   wasting the full run. `mkdir -p` is idempotent, so always keep it.
3. **Background long jobs with `setsid`, never `nohup`.** The opencode shell tool
   kills its process group on timeout; a `nohup` run died at 5% progress.
4. `-sns` strips literal `[MUSIC]`/`[BLANK_AUDIO]` tokens. Keep cues as a soft
   track; burn in only on final exports.

Full detail (quality caveats, Resolve import steps, flag notes) is in the
`video` skill - load it when the request involves subtitles, ProRes, or YouTube.

## Other video workflows
Resolve-compatible transcoding and YouTube export recipes are in the `video` skill.
Load it rather than improvising ffmpeg settings. Default to **ProRes Proxy**
(`-c:v prores_ks -profile:v 0`). DNxHR LB is a fallback only: it hit an ffmpeg
assertion failure on a 4h stream and left an unplayable file.

## Long form vs shorts (same master)
User cuts in Resolve. One master + one full-length SRT serves both outputs; the
SRT must **never** be burned in during transcoding.

- "make it editable" / "make stream editable for davinci" -> produce a ProRes Proxy
  master in `~/Videos/obs_footage/edit/`, keep subtitles out of it
- **Long form** -> Deliver → Subtitle Settings → leave *Export Subtitle* unticked
- **Shorts** -> tick *Export Subtitle* → **Burn into video**, render marked range
- Both render from the **same timeline**; it is one checkbox difference
- Cut shorts on the **full-length timeline**. Copying a clip to a new timeline
  starts that timeline at 00:00:00 while cues keep their original stamp, so subs
  land wrong or vanish.
- Never delete the master or the original source without explicit confirmation

