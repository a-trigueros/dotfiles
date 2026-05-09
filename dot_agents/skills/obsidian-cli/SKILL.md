---
name: obsidian-cli
description: Interact with Obsidian vaults using Obsidian CLI to read, create, search, and manage notes, tasks, properties, tags, plugins, themes, and workspace state. Use when the user asks to work with their Obsidian vault from pi.
---

# Obsidian CLI

Use the shell command `obsidian ...`.

Requires Obsidian desktop app to be running.

## Command reference

Run `obsidian help` to see all available commands. This is always up to date.
Docs: <https://help.obsidian.md/cli>

## Syntax

Parameters use `=`:

```bash
obsidian create name="My Note" content="Hello world"
```

Flags are booleans with no value:

```bash
obsidian create name="My Note" overwrite
```

For multiline content, use `\n` and `\t`.

## File targeting

Many commands accept `file` or `path`. If omitted, active file is used.

- `file=<name>` resolves like wikilinks
- `path=<path>` is exact from vault root (`folder/note.md`)

## Vault targeting

Use `vault=<name>` first to target specific vault:

```bash
obsidian vault="My Vault" search query="test"
```

## Common patterns

```bash
obsidian read file="My Note"
obsidian create name="New Note" content="# Hello"
obsidian append file="My Note" content="New line"
obsidian search query="search term" limit=10
obsidian property:set name="status" value="done" file="My Note"
obsidian tasks todo
obsidian tags sort=count counts
obsidian backlinks file="My Note"
```

Use `total` on list commands for counts.

## Plugin development loop

After plugin/theme changes:

1. Reload plugin

   ```bash
   obsidian plugin:reload id=my-plugin
   ```

2. Check errors

   ```bash
   obsidian dev:errors
   ```

3. Verify UI

   ```bash
   obsidian dev:screenshot path=screenshot.png
   obsidian dev:dom selector=".workspace-leaf" text
   ```

4. Check console

   ```bash
   obsidian dev:console level=error
   ```

## Safety

Dangerous commands (`eval`, `dev:cdp`, `dev:debug`, `restart`) should only be run
when explicitly requested by user.
