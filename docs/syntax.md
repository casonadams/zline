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

## 4. Execution Model

- **Compile Once**: When `zline init` runs, it tokenizes all arguments into internal arrays once during shell launch (< 0.2 ms).
- **Zero-Cost Renders**: On every Enter keystroke, `zline` does **zero** flag parsing and **zero** subshell forks, directly invoking the pre-compiled segment handlers in microseconds.
