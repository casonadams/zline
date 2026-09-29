# Configuration Syntax

`zline` replaces Powerlevel10k's 1,600 lines of uppercase global variables (`POWERLEVEL9K_*`) with a concise, declarative, composable configuration model based on native Zsh arrays.

---

## 1. Native Zsh Array Syntax (No Quotes Required)

Prompts are declared using `zline_left` and `zline_right` arrays. You do **not** need to wrap each segment and its flags in quotes—native unquoted tokens are parsed directly:

```zsh
# 1. Select visual preset and global flags
zline preset pure --transient --no-icons

# 2. Configure left prompt segments (unquoted)
zline_left=(
  dir --shorten 1 --anchor git
  git --clean 2 --dirty 3
  rust
  package
  newline
  prompt_char
)

# 3. Configure right prompt segments (unquoted)
zline_right=(
  exec_time --min 2
  time --color cyan
)

# 4. Initialize prompt
zline init
```

You only need quotes if an argument value contains spaces (e.g. `--alias "github.com=gith"` or `--icon " "`) or when explicitly passing an empty string (e.g. `--icon ""`).

---

## 2. Universal Segment Flags

Every segment in `zline` universally supports icon, color, surround, and format overrides:

| Flag | Example | Description |
| :--- | :--- | :--- |
| `--icon <sym>` | `git --icon " "` | Overrides the segment's default icon with a custom glyph. |
| `--icon ""` | `git --icon ""` | Suppresses the icon for this specific segment (renders only text/content). |
| `--color <col>` / `--fg <col>` | `time --color cyan` | Sets text/foreground color (Base16 `0`–`15`, color name, 256-index, or hex `#RRGGBB`). |
| `--bg <col>` | `dir --bg 4` | Sets background block color (in Powerline and Rainbow modes). |
| `--prefix <str>` | `git --prefix "["` | Prepends arbitrary string before segment content. |
| `--suffix <str>` | `git --suffix "]"` | Appends arbitrary string after segment content. |
| `--format <fn>` | `dir --format my_fmt` | Post-processes segment content with a custom Zsh function setting `$REPLY`. |

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

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--transient` | Off | Automatically collapses past multi-line prompts into a minimal `❯` symbol on Enter. |
| `--transient-dir` | Off | Retains directory in collapsed transient prompt instead of symbol-only (`~/src/zline ❯`). |
| `--no-transient` | On | Disables transient prompt (retains full prompts in terminal scrollback). |
| `--no-icons` | Off | Suppresses default segment icons globally across all segments (pure text mode). |
| `--icons` | On | Enables default segment icons. |
| `--no-osc` | Off | Disables OSC 133 (semantic shell integration) and OSC 7 (working directory) escape codes. |
| `--ascii` | Off | Replaces all Nerd Font symbols and Powerline glyphs with pure ASCII fallbacks (`>`, `<`, `+`, `|`). |
| `--nerdfont` | On | Enables Nerd Font v3 glyphs and Powerline separators. |
| `--frame <none\|left\|full>` | `none` | Renders corner frame connectors (`╭─`, `╰─`). |
| `--frame-shape <rounded\|sharp\|double>` | `rounded` | Selects frame corner glyph style (`╭─` / `┌─` / `╔═`). |
| `--connect <solid\|dashed\|dotted\|char>` | None | Draws a connecting line (`─`, `┄`, `┈`) between left and right prompts on multiline layouts. |
| `--connect-color <col>` | `8` | Color of the connecting line (default: `8` / grey). |
| `--rprompt-line <1\|2>` | `1` | Embeds right prompt into line 1 via connecting line or keeps native RPROMPT on the input line. |
| `--title` | On | Automatically updates terminal window/tab title with current path and running commands. |
| `--no-title` | Off | Disables terminal window/tab title updates. |
| `--title-format <fmt>` | `%~` | Custom prompt format string for idle window titles. |
| `--notify [secs]` | Off | Enables desktop notifications via OSC 777 / OSC 9 when commands exceed duration threshold. |
| `--no-notify` | On | Disables desktop notifications. |
| `--hyperlinks` | Off | Formats directory paths and Git repositories as clickable OSC 8 hyperlinks. |
| `--no-hyperlinks` | On | Disables clickable OSC 8 hyperlinks. |
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
| `zline notify [on\|off\|threshold\|status]` | Configures long-running command desktop notifications (OSC 777 / OSC 9). |
| `zline version` | Prints active `zline` release version. |

---

## 6. Execution Model

- **Compile Once**: When `zline init` runs, it tokenizes all arguments into internal arrays once during shell launch (< 0.2 ms).
- **Zero-Cost Renders**: On every Enter keystroke, `zline` does **zero** flag parsing and **zero** subshell forks, directly invoking the pre-compiled segment handlers in microseconds.
