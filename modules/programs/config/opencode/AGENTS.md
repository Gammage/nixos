# opencode instructions

## ADB (Android file transfer)
- Package: `pkgs.android-tools` (configured inline in `hosts/desktop/default.nix:18`)
- Usage: enable USB Debugging on phone, then `adb pull /sdcard/DCIM/Camera/ <dest>`

## Session notes / compaction
- When asked to "make a note" or "compact recent events", create an Obsidian note:
  1. `nvim -e -c "Obsidian new_from_template session-summary" -c "wq"` (run from vault root `/home/ben/notes`)
  2. Edit: add descriptive alias, fill in sections (summary, files, decisions, lessons, questions)
  3. Move to llm_notes: `mv "files/<ID>.md" "files/llm_notes/<ID>.md"`

## If working with obsidian/notes directory;
 - Enforce naming conventions via note_id_func/frontmatter

## Project Zomboid dedicated server
- Save location: `/home/ben/Zomboid/Saves/Multiplayer/MainServer`
- Server config: `/home/ben/Zomboid/Server/MainServer.ini`
- Server launcher: `/home/ben/.local/share/Steam/steamapps/common/ProjectZomboid/projectzomboid/start-server.sh`
- Built-in backups: `/home/ben/Zomboid/backups/startup/backup_*.zip` (made on server start)
- Crash symptom: "SANITY CHECK FAIL / CRC mismatch" in `.../MainServer/blam/*_error.txt` -> affected buildings revert to default terrain
- Fix: restore affected `map/X/Y.bin` chunks (or full save) from a pre-crash backup
- Server heap: raised to `-Xms4096m -Xmx8192m` (was 2048m)
- PENDING TASK: user wants a daily cron backup of MainServer; run only when server is stopped
- Safety copies of the corrupt/old saves were kept as `*_CORRUPTED_*` and `*_pre_revert_*` folders under `Saves/Multiplayer/`

## Video subtitles (whisper-cpp → DaVinci Resolve)

User is on **DaVinci Resolve FREE (21.1)**. Do not suggest buying Studio. Free
edition fully supports adding/importing SRT, editing, styling and burning in —
only AI transcription is Studio-gated. Never claim subtitles are unavailable.

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
ProRes conversion and YouTube export recipes are in the `video` skill.
Load it rather than improvising ffmpeg settings.

