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
