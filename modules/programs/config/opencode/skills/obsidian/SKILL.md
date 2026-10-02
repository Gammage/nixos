---
name: obsidian
description: Use this file for creating, editing and organising the note directory or files (obsidian vault) unless other specified by user prompt
---

# Agent Notes — Obsidian guidelines

## Commands
- Use Obsidian new — DO NOT use ObsidianNew, it is deprecated and will throw an error
- DO NOT create notes manually (write tool, echo, etc.) — always use the nvim command, then edit the file if necessary

Use the following syntax for all obsidian commands run from the command line: nvim -e -c "Obsidian <command> <args>" -c "wq" 
    - Create a new note `Obsidian new "<title>"`
    - Create a new note from template `Obsidian new_from_template "<title>"`

## Vault layout
- Vault root: `/home/ben/notes` — run obsidian commands from there
- `templates/` — note templates, including `session-summary.md`
- `files/llm_notes/` — where finished session notes belong
- Vault is a git repo; commits are recoverable

## Note ID convention
Filename stem **and** the `id:` frontmatter field must both be:

```
<10-digit unix seconds>-<4 UPPERCASE letters>      e.g. 1779065124-ZBDA
```

```bash
date +%s          # 10-digit seconds — NOT %s%3N, that yields 13 digits
```

The letters look random but are part of the ID; keep whatever the plugin
generates. Never invent an ID by hand.

Known drift: `files/llm_notes/1779974292202-UVMX.md` had a 13-digit
(milliseconds) ID. Fixed 2026-10-02 to `1779974292-UVMX`.

## Session note workflow
When asked to "make a note" or "compact recent events":

1. From the vault root, create from the template:
   `nvim -e -c "Obsidian new_from_template session-summary" -c "wq"`
2. Edit the new file: add a descriptive alias, then fill every section
   (Date, Summary, Files changed/created, Key decisions, Lessons learnt,
   Open questions). Leave no section empty.
3. Move it out of the root into place:
   `mv "files/<ID>.md" "files/llm_notes/<ID>.md"`
4. Verify the filename and the `id:` field agree before finishing.
