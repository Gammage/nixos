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

