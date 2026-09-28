# Event Hooks & Extensibility

`zline` features an event-driven architecture that executes operations only when state changes, avoiding unnecessary re-computation during repeated command prompts.

---

## 1. Lifecycle Events

Register custom callback functions using `zline_hook add <event> <callback>`:

```zsh
zline_hook add <event> <function_name>
```

| Event | Trigger | Description |
| :--- | :--- | :--- |
| `chpwd` | Directory change (`cd`) | Triggered when `$PWD` changes. Ideal for path calculations, Git root detection, and environment discovery. |
| `preexec` | Command execution | Triggered before a user command begins. Receives the command string in `$1`. |
| `precmd` | Prompt assembly | Triggered before the prompt is rendered. Exit status is stored in `$_zline_last_exit_code`. |
| `keymap_select` | ZLE Vi-mode toggle | Triggered when switching between insert (`main`) and normal (`vicmd`) mode. |
| `pre_render` | Prompt rendering start | Triggered immediately before segments are assembled. |
| `post_render` | Prompt rendering finish | Triggered after `PROMPT` and `RPROMPT` are assigned. |
| `zshexit` | Shell termination | Triggered on shell exit to clean up workers and file descriptors. |

---

## 2. Creating Custom Segments

A custom segment is simply a Zsh function named `zline_segment_<name>`. Set the global return parameters:

```zsh
zline_segment_mybadge() {
  # 1. Compute logic with zero subshells
  [[ -z "$MY_ENVIRONMENT" ]] && return 0

  # 2. Assign output fields
  _zline_ret_content="$MY_ENVIRONMENT"
  _zline_ret_fg="6"       # cyan
  _zline_ret_bg="0"       # black
  _zline_ret_icon="⚡ "
}

# Add to your prompt:
zline_left=(dir git mybadge newline prompt_char)
zline init
```

---

## 3. Custom Path Formatter

The `dir` segment supports custom formatters via the `--format <function>` option. Use the `$REPLY` global to avoid subshell forks:

```zsh
my_custom_path() {
  local p="${1/#$HOME/~}"
  # Replace company root with an icon
  p="${p//src\/github.com\/myorg/🏢}"
  REPLY="$p"
}

zline_left=(
  'dir --format my_custom_path --color 4'
  git
  prompt_char
)
zline init
```
