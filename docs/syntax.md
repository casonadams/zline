# Configuration Syntax

`zline` replaces Powerlevel10k's 1,600 lines of uppercase global variables (`POWERLEVEL9K_*`) with a concise, declarative, composable configuration model based on native Zsh arrays.

---

## 1. Native Zsh Array (Recommended)

Prompts are declared using `zline_left` and `zline_right` arrays:

```zsh
# 1. Select visual preset
zline preset powerline --transient

# 2. Configure left prompt segments
zline_left=(
  'dir --shorten 1 --alias github.com=gith --anchor git'
  'git --clean 2 --dirty 3'
  newline
  prompt_char
)

# 3. Configure right prompt segments
zline_right=(
  'status --hide-zero'
  'exec_time --min 2'
)

# 4. Initialize prompt
zline init
```

Each element in the array represents a segment name followed by its flags.

---

## 2. Unquoted Array Syntax

If you prefer unquoted lines in your `.zshrc`, `zline` natively parses unquoted token streams:

```zsh
zline_left=(
  dir --shorten 1 --color 4
  git --clean 2 --dirty 3
  newline
  prompt_char
)
```

---

## 3. Presets with Inline Overrides

You can start from any built-in preset and selectively override segments:

```zsh
# Load the rainbow preset with transient prompt enabled
zline preset rainbow --transient

# Override directory shortening
zline_left=(
  'dir --shorten 2 --anchor git'
  'git --clean 10 --dirty 11'
  newline
  prompt_char
)
zline init
```

---

## 4. Global Style Flags

You can customize prompt behavior using flags on `zline preset` or `zline style`:

| Flag | Description |
| :--- | :--- |
| `--transient` | Automatically collapses past prompts into a minimal `❯` symbol on Enter. |
| `--transient-dir` | Retains directory in collapsed transient prompt instead of symbol-only. |
| `--frame <none\|left\|full>` | Renders corner frame connectors (`╭─`, `╰─`). |
| `--connect <char>` | Draws a connecting line (`·`, `─`) between left and right prompts on multiline layouts. |
| `--connect-color <col>` | Color of the connecting line (default: `8` / grey). |
| `--hyperlinks` | Formats directory paths and Git repositories as clickable OSC 8 hyperlinks. |
| `--title` | Automatically updates terminal tab/window titles with current path and running commands. |
| `--ascii` | Replaces all Nerd Font symbols and Powerline glyphs with pure ASCII fallbacks. |
| `--no-osc` | Disables OSC 133 and OSC 7 terminal escape codes. |

---

## 5. CLI Commands Reference

| Command | Description |
| :--- | :--- |
| `zline preset <name>` | Loads built-in layout or curated color theme (`powerline`, `lean`, `rainbow`, `pure`, `catppuccin`, `tokyonight`, `nord`, `gruvbox`). |
| `zline preset list` | Displays all available presets and curated themes. |
| `zline preset show <name>` | Dumps the full source definition of a preset. |
| `zline style <name>` | Configures visual styling flags (`--transient`, `--ascii`, `--no-osc`, `--frame`, `--connect`). |
| `zline init` | Compiles segment arguments and installs Zsh hooks. |
| `zline bench [--profile] [N]` | Runs prompt latency benchmarks or per-segment micro-profiling over `N` iterations. |
| `zline compare` | Executes comparative benchmark against subshell-based and standard prompt designs. |
| `zline doctor` | Comprehensive health check (shell version, UTF-8 locale, cache directory, valid segments). |
| `zline configure` | Interactive setup wizard for generating a custom configuration. |
| `zline migrate <p10k_file>` | Automatically translates Powerlevel10k configurations into idiomatic `zline` syntax. |
| `zline compile` / `clean` | Manages memory-mapped `.zwc` wordcode compilation. |
| `zline update` | Pulls the latest release and recompiles bytecode. |
| `zline version` | Prints active `zline` release version. |

---

## 6. Execution Model

- **Compile Once**: When `zline init` runs, it tokenizes all arguments into internal arrays once during shell launch (< 0.2 ms).
- **Zero-Cost Renders**: On every Enter keystroke, `zline` does **zero** flag parsing and **zero** subshell forks, directly invoking the pre-compiled segment handlers in microseconds.
