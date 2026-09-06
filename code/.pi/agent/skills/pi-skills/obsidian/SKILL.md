---
name: obsidian
description: Obsidian vault access via the obsidian CLI (local REST API). Read, create, append, list tasks/tags/backlinks, and full-text search.
---

# Obsidian

Access your Obsidian vault at `/home/william-nobara/obsidian-notes` using the `obsidian` CLI via the Obsidian Local REST API plugin.

## Setup

The `obsidian` CLI (`~/.local/bin/obsidian`) and the REST API plugin are already configured. The API key (`$OBSIDIAN_MCP_TOKEN`) is exported in your shell profile.

## Core Commands

### Read a note

```bash
obsidian read path="My Note.md"        # Exact path from vault root
```

### List files

```bash
obsidian files                             # All files
obsidian files folder="Daily Notes"        # Files in a folder
obsidian files ext=md                      # Only markdown (default)
obsidian files ext=png                     # Images only
obsidian files total                       # File count
```

### Full-text search

Obsidian CLI has no built-in search. Use `rg` directly on the vault:

```bash
rg -i "search term" /home/william-nobara/obsidian-notes --md -l   # List matching files
rg -i "search term" /home/william-nobara/obsidian-notes --md -C 2 # With context
```

### Create a note

```bash
obsidian create path="folder/New Note.md" content="# Heading\n\nBody text"
obsidian create path="folder/New Note.md" content="# Heading" open  # Open after create
```

### Append to a note

```bash
obsidian append path="Note.md" content="\n- new list item"
obsidian append path="Note.md" content="more text" --inline   # No newline
```

### Tasks

```bash
obsidian tasks                                  # All incomplete tasks
obsidian tasks path="Project.md"                # Tasks in a file
obsidian tasks total                            # Count
obsidian tasks done                             # Show completed
obsidian task ref="Note.md:42" toggle           # Toggle a task at line 42
obsidian task ref="Note.md:42" done             # Mark done
```

### Tags

```bash
obsidian tags                                   # All tags with counts
obsidian tags path="Note.md"                    # Tags in a file
obsidian tags total                             # Count
```

### Backlinks (what links to a note)

```bash
obsidian backlinks path="Note.md"
obsidian backlinks path="Note.md" total
obsidian backlinks path="Note.md" counts        # With link counts
```

### Orphans & Dead ends

```bash
obsidian orphans       # Files with no incoming links
obsidian deadends      # Files with no outgoing links
```

### Vault info

```bash
obsidian vault
obsidian vaults        # List known vaults
```

### Delete a note

```bash
obsidian delete path="Old Note.md"             # Trash
obsidian delete path="Old Note.md" permanent   # Skip trash
```

## Architecture Research Timeline

Research notes (architecture analysis, investigations, codebase onboarding) go into the `Architecture` folder organized by ISO week.

### Folder structure

Each note lives under the ISO week it was created:

```
Architecture/
├── 2026-W22/
│   └── meseeks-pipelines.md
├── 2026-W23/
│   ├── Dotfiles Analysis.md
│   └── route-store-ui-build.md
├── 2026-W24/
│   └── ...
```

### Creating a new research note

1. Determine current ISO week: `date '+%Y-W%V'`
2. Ensure the week folder exists under `Architecture/`
3. Create the note inside it:

```bash
week=$(date '+%Y-W%V')
mkdir -p "Architecture/$week"
obsidian create path="Architecture/$week/My Research.md" content="# My Research\n\n**Date:** $(date '+%Y-%m-%d')\n"
```

### Linking between Architecture notes

Use wiki-style links with the full path from vault root:

```
[[Architecture/2026-W24/mermaid-ascii]]
```

## Notes

- Use `path=` for exact file paths (relative to vault root), `file=` for wiki-style name lookup
- All commands target the `obsidian-notes` vault by default
- The REST API must be running (Obsidian open with plugin enabled)
