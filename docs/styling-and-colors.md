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

## 3. Font Modes

- **Nerd Fonts v3 (Default)**: Uses official Nerd Font symbols (` `, ``, `❯`).
- **ASCII Mode**: Pure ASCII fallback (`zline style lean --ascii`) using `[`, `]`, `>`, `$` characters.
