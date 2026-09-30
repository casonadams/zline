# Migrating from Powerlevel10k

Migrating from Powerlevel10k to `zline` replaces up to 1,600 lines of `~/.p10k.zsh` with a clean 15-line declaration in your `~/.zshrc`.

---

## Direct Feature Comparison

| Powerlevel10k | `zline` Equivalent |
| :--- | :--- |
| `typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1` | `dir --shorten 1` |
| `typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique` | `dir --shorten 1 --anchor git` |
| `typeset -g POWERLEVEL9K_DIR_ANCHOR_FILES=(.git)` | `dir --anchor git` |
| `typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=2` | `git --clean 2` |
| `typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=3` | `git --dirty 3` |
| `typeset -g POWERLEVEL9K_STATUS_OK=false` | `status --hide-zero` |
| `typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2` | `exec_time --min 2` |
| `typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always` | `zline style <style> --transient` |
| `typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet` | Built-in by default (`instant.zsh`) |

---

## Translating Your Configuration

### In Powerlevel10k:
```zsh
# ~/.zshrc
source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ~/.p10k.zsh (spread across 1,600 lines of global env vars)
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs newline prompt_char)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time)
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
typeset -g POWERLEVEL9K_DIR_FOREGROUND=4
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=2
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=3
```

### In `zline`:
```zsh
# ~/.zshrc
source ~/.zline/zline.zsh

zline preset powerline --transient

zline_left=(
  'dir --shorten 1 --anchor git --color 4'
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

## Automated Migration Tool

`zline` includes an automated migration tool that parses your existing `~/.p10k.zsh` configuration and generates an equivalent `zline` configuration:

```zsh
zline migrate ~/.p10k.zsh ~/.zshrc.zline
```

### Supported Segment Mappings

| Powerlevel10k Element | `zline` Segment |
| :--- | :--- |
| `dir` | `dir` (`--shorten 1 --anchor git`) |
| `vcs` | `git` (`--clean 2 --dirty 3`) |
| `status` | `status` (`--hide-zero`) |
| `command_execution_time` | `exec_time` (`--min 2`) |
| `context` | `user_host` |
| `prompt_char` | `prompt_char` |
| `virtualenv`, `anaconda`, `pyenv` | `venv` |
| `nodenv`, `nvm`, `node_version` | `node` |
| `kubecontext` | `k8s` |
| `time` | `time` |
| `background_jobs` | `jobs` |
| `aws` | `aws` |
| `gcloud`, `google_app_cred` | `gcp` |
| `azure` | `azure` |
| `docker_context` | `docker` |
| `rust_version` | `rust` |
| `go_version` | `golang` |
| `dotnet_version` | `dotnet` |
| `php_version` | `php` |
| `java_version` | `java` |
| `ruby_version`, `rbenv`, `rvm` | `ruby` |
| `elixir_version` | `elixir` |
| `crystal_version` | `crystal` |
| `julia_version` | `julia` |
| `lua` | `lua` |
| `perl` | `perl` |
| `erlang_version` | `erlang` |
| `terraform` | `terraform` |
| `package` | `package` |
| `battery` | `battery` |
| `load` | `load` |
| `ram` | `ram` |
| `direnv` | `direnv` |
| `nix_shell` | `nix_shell` |
| `vi_mode` | `vi_mode` |
| `shlvl` | `shlvl` |
| `os_icon` | `os` |

---

## Why Migrate?

1. **No External C++ Binaries**: Powerlevel10k requires downloading and running `gitstatusd`. `zline` is 100% pure Zsh.
2. **Modern Protocols**: Native OSC 133 semantic prompt markings, OSC 7 working directory inheritance, and OSC 8 hyperlinks.
3. **Zero Namespace Pollution**: No hundreds of `POWERLEVEL9K_*` global strings polluting your shell symbol table.
4. **Active & Maintainable**: Built cleanly on modern Zsh 5.8+ primitives.
