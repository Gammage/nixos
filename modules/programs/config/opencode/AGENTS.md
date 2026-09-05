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

