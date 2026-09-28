<p align="center">
  <img src="www/favicon.svg" width="90" height="90" alt="zline logo" />
</p>

<h1 align="center">zline</h1>

<p align="center">
  <b>Fast, modern, and flexible pure-Zsh prompt engine.</b><br>
  A streamlined replacement for Powerlevel10k with zero subshell forks, Base16 palette harmony, and declarative array configuration.
</p>

<p align="center">
  <a href="https://github.com/casonadams/zline/actions/workflows/ci.yml"><img src="https://github.com/casonadams/zline/actions/workflows/ci.yml/badge.svg" alt="CI Status" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT" /></a>
  <img src="https://img.shields.io/badge/zsh-5.8%2B-blueviolet.svg" alt="Zsh 5.8+" />
  <img src="https://img.shields.io/badge/render-%3C%200.7ms-success.svg" alt="Sub-millisecond render" />
  <img src="https://img.shields.io/badge/subshells-0-brightgreen.svg" alt="Zero subshells" />
</p>

---

## Highlights

- ⚡ **Sub-Millisecond Synchronous Rendering**: Renders prompts in under **0.7 ms** with **0 subshell forks** on the critical path.
- 📦 **100% Pure Zsh**: Zero compiled C++ daemons or binary downloads. Runs anywhere Zsh 5.8+ is installed (macOS, Linux, BSDs, Alpine/musl, Termux).
- 🧩 **Declarative Array Syntax**: Replaces 1,600 lines of uppercase global environment variables (`POWERLEVEL9K_*`) with concise, composable Zsh arrays.
- 🎨 **Base16 / Term16 Palette First**: Standardizes on ANSI 0–15 colors, adapting harmoniously to any terminal theme (Catppuccin, Tokyo Night, Gruvbox, Nord, Dracula).
- 📁 **Smart Path Shortening**: Intermediate directory shortening (`~/s/g/c/zline`), path aliases (`github.com=gith`), Git root anchoring, and custom formatters via zero-fork `$REPLY` references.
- 🌿 **Two-Phase Git Status**: Synchronous branch detection in **0.07 ms** + non-blocking asynchronous background worker (`zle -F`) for working tree dirty state.
- 🛠️ **28 Built-In Segments**: Rich ecosystem covering cloud (AWS, K8s, Terraform, Docker), runtimes (Node, Rust, Go, Python, Ruby, PHP, Java, .NET, Lua, Zig), environments (Nix, Direnv), system metrics (RAM, Load, Battery), and universal `.tool-versions` detection.
- 🚀 **Instant Prompt (< 0.1 ms)**: Pre-compiled static snapshot displayed immediately upon terminal launch before `.zshrc` finishes executing.
- 🧼 **Transient Prompt**: Automatically collapses multi-line prompts down to a minimal `❯` symbol on Enter, keeping your terminal scrollback pristine.
- 🌐 **Modern Terminal Protocols**: Native OSC 133 semantic shell integration (Ghostty, Kitty, WezTerm, iTerm2), OSC 7 directory inheritance, and OSC 8 hyperlinks.

---

## Quickstart

### 1. With [zload](https://github.com/casonadams/zload) (Recommended)

```zsh
# In ~/.zshrc
plugins=(
  casonadams/zline
)
zload "${plugins[@]}"

zline preset powerline --transient
zline init
```

### 2. Manual Installation

```zsh
git clone https://github.com/casonadams/zline.git ~/.zline
```

Add to your `~/.zshrc`:

```zsh
source ~/.zline/zline.zsh

zline preset powerline --transient

zline_left=(
  'dir --shorten 1 --alias github.com=gith --anchor git'
  'git --clean 2 --dirty 3'
  newline
  prompt_char
)

zline_right=(
  'status --hide-zero'
  'exec_time --min 2'
)

zline init
```

---

## Visual Presets & Curated Themes

`zline` includes built-in structural layout presets and curated color themes:

### Layout Presets

| Preset | Description | Command |
| :--- | :--- | :--- |
| **Powerline** | Multi-colored background blocks with Powerline arrow glyphs (``, ``) | `zline preset powerline` |
| **Lean** | Modern, flat, space-separated layout with crisp foreground colors | `zline preset lean` |
| **Rainbow** | High-contrast vivid blocks for rapid visual parsing | `zline preset rainbow` |
| **Pure** | Minimalist two-line prompt inspired by Sindre Sorhus's Pure prompt | `zline preset pure` |

### Curated Color Themes

| Theme | Description | Command |
| :--- | :--- | :--- |
| **Catppuccin** | Soothing pastel palette based on Mocha | `zline preset catppuccin` |
| **Tokyo Night** | Dark, vibrant aesthetic inspired by Tokyo nightlife | `zline preset tokyonight` |
| **Nord** | Arctic, north-bluish clean palette | `zline preset nord` |
| **Gruvbox** | Warm retro groove color scheme | `zline preset gruvbox` |

List all presets with `zline preset list` or inspect preset code with `zline preset show <name>`.

---

## Performance Benchmarks

Measured on macOS (Apple Silicon arm64, Zsh 5.9):

```
============================================================
              zline Performance Benchmarks                  
============================================================

Benchmark                        Iterations       Per Op     Target   Status
-------------------------------- ---------- ------------ ---------- --------
Sync Prompt Render (Powerline)         1000      0.66 ms  < 1.50 ms     PASS
Sync Prompt Render (Lean)              1000      0.52 ms  < 1.00 ms     PASS
Directory Shortening & Anchor          1000      0.10 ms  < 0.15 ms     PASS
Synchronous Git HEAD Reader            1000     0.072 ms  < 0.15 ms     PASS
Instant Prompt Load                     500     0.057 ms  < 0.50 ms     PASS
============================================================
ALL BENCHMARKS PASSED!
```

Run benchmarks locally:
```zsh
zsh benchmark/bench.zsh
```

---

## Documentation

- [Configuration Syntax](docs/syntax.md)
- [Built-in Segments Reference](docs/segments.md)
- [Styling & Base16 Colors](docs/styling-and-colors.md)
- [Event Hooks & Extensibility](docs/hooks-and-extensibility.md)
- [Migrating from Powerlevel10k](docs/migrating-from-p10k.md)
- [Unix Manual Page](man/man1/zline.1) (`man zline`)

Interactive Web Playground: [https://casonadams.github.io/zline/](https://casonadams.github.io/zline/)

---

## License

MIT © [Cason Adams](https://github.com/casonadams)
