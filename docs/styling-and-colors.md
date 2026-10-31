# Styling & Base16 Colors

`zline` standardizes on **Base16 / Term16 (0–15)** ANSI colors, ensuring your prompt adapts harmoniously to any terminal color scheme (Catppuccin, Tokyo Night, Gruvbox, Dracula, Solarized, Nord) without manual adjustments.

---

## 1. Base16 Color Table

| Code | Semantic Name | Suggested Prompt Role |
| :--- | :--- | :--- |
| `0` / `8` | `black` / `bright-black` | Muted metadata, separators |
| `1` / `9` | `red` / `bright-red` | Failed status code, root `#`, errors |
| `2` / `10` | `green` / `bright-green` | Clean Git working tree, command success |
| `3` / `11` | `yellow` / `bright-yellow` | Dirty Git status, exec duration, warnings |
| `4` / `12` | `blue` / `bright-blue` | Current working directory, branch icon |
| `5` / `13` | `magenta` / `bright-magenta` | Language runtimes (Python, Node) |
| `6` / `14` | `cyan` / `bright-cyan` | Cloud context (K8s, Docker, AWS) |
| `7` / `15` | `white` / `bright-white` | Active prompt symbol, primary text |

Both numbers (`2`, `14`) and semantic names (`green`, `bright-cyan`) can be used interchangeably in segment flags.

---

## 2. Visual Presets

### Powerline
```zsh
zline preset powerline
```
Uses background color blocks connected by Powerline arrow glyphs (`` U+E0B0 and `` U+E0B2).

### Lean
```zsh
zline preset lean
```
Modern flat layout with zero background blocks. Segments are separated by clean spaces.

### Rainbow
```zsh
zline preset rainbow
```
Vivid, high-contrast background blocks designed for rapid visual parsing.

### Pure
```zsh
zline preset pure
```
Minimalist two-line prompt inspired by Sindre Sorhus's Pure prompt.

---

## 3. Frames & Connecting Lines

On multiline prompts, `zline` can render connecting lines between left and right segments and draw decorative corner frames:

```zsh
zline style powerline --frame full --frame-shape rounded --connect dashed --connect-color 8
```

### Frame Options

| Flag | Options | Description |
| :--- | :--- | :--- |
| `--frame` | `none`, `left`, `full` | Selects corner frame connector layout (default: `none`). |
| `--frame-shape` | `rounded`, `sharp`, `double` | Corner glyphs: rounded (`╭─`), sharp (`┌─`), or double (`╔═`). |
| `--connect` | `solid`, `dashed`, `dotted`, `none` | Connecting line glyph: solid (`─`), dashed (`┄`), dotted (`┈`), or custom character. |
| `--connect-color` | `0`–`15` / color name | Sets the color for connecting line glyphs (default: `8` / grey). |
| `--rprompt-line` | `1`, `2` | Placement of right prompt: `1` embeds right segments into line 1 via connecting line; `2` keeps native right prompt on the input line. |

---

## Responsive Layout

When the left prompt is wider than the terminal, zline shrinks it in stages until it fits:

1. `dir` shortens ancestors, then collapses to `.../last`.
2. Git branch names longer than 16 characters are truncated with `…`.
3. Git status details are dropped (the branch stays).
4. Remaining segments are dropped lowest-priority first (rightmost first on ties). `dir`, `prompt_char` and `vi_mode` are never dropped; `status` and `git` rank above most others.

The right prompt drops segments from the left and respects `ZLE_RPROMPT_INDENT`. The prompt is re-rendered on terminal resize. Git status loads in the background; cached details stay visible while a refresh is pending, so they can be briefly out of date after a command.

---

## 4. Font Modes

- **Nerd Fonts v3 (Default)**: Uses official Nerd Font symbols (` `, ``, `❯`).
- **ASCII Mode**: Pure ASCII fallback (`zline style lean --ascii`) using `[`, `]`, `>`, `$` characters.
