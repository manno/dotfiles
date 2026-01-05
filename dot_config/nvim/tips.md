# #0 Config specific reminders

- Surround - `sa%"` `sa$'` `saE"` `srb"` `sr"'` `sd"`
- `<C-w>d` shows diagnostic at cursor in a floating window

# #1 Global Command: `:g/pattern/cmd`

Run Ex command on all matching lines

| Command | Effect |
|---------|--------|
| `:g/TODO/d` | Delete all TODOs |
| `:g/^$/d` | Delete empty lines |
| `:g/error/t$` | Copy error lines to end |
| `:g/func/norm A;` | Append `;` to all functions |

# #2 Command-line Registers: `Ctrl-r`

Insert register contents in : or / prompt

| Shortcut | Inserts |
|----------|---------|
| `Ctrl-r Ctrl-w` | Word under cursor |
| `Ctrl-r "` | Last yank |
| `Ctrl-r /` | Last search pattern |
| `Ctrl-r =` | Expression (e.g., `system('date')`) |

# #3 Normal on Selection: `:'<,'>norm`

Run normal mode commands on each selected line

Select lines, then:
```
:'<,'>norm A,        → Append comma to each line
:'<,'>norm I#        → Comment each line
:'<,'>norm @q        → Run macro on each line
:'<,'>norm f=lD      → Delete after = on each
```

# #4 The `g` Commands You Need

Navigation jumps with g prefix

| Command | Effect |
|---------|--------|
| `gi` | Go to last insert position + insert mode |
| `g;` | Jump to previous change |
| `g,` | Jump to next change |
| `gv` | Reselect last visual selection |

# #5 Marks: Hidden Power

Auto-marks vim sets for you

| Mark | Jumps to |
|------|----------|
| ``` `` ``` | Previous position (toggle back!) |
| `` `. `` | Last change position |
| `` `" `` | Position when file was last closed |
| `` `[ `` / `` `] `` | Start/end of last yank or change |

# #6 Command History Window: `q:`

Editable command history in buffer

```
q:       opens command history window
q/       opens search history window
Ctrl-f   in cmdline switches to window mode

Edit any line, hit Enter to execute
```
---

Sources:
* https://github.com/Piotr1215/youtube/blob/main/10-nvim-tricks/presentation.md
