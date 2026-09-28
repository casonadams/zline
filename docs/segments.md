# Built-in Segments Reference

`zline` comes with a comprehensive library of modular, zero-subshell segments.

---

## `dir` (Directory)

Displays the current working directory with smart truncation, aliases, and Git anchoring.

```zsh
dir --shorten 1 --alias github.com=gith --anchor git --color 4
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--shorten <N>` | `0` | Shorten intermediate directory components to `N` characters (`1` $\rightarrow$ `~/s/g/c/zline`). |
| `--keep-last <N>` | `1` | Number of trailing directory components to keep full. |
| `--alias <k=v>` | None | Replaces path component matching `k` with `v` (can be repeated). |
| `--anchor <git>` | `none` | Keeps Git repository root name full while shortening directories above it. |
| `--color <col>` | `4` | Foreground color (in lean/pure modes). |
| `--bg <col>` | `4` | Background color (in powerline/rainbow modes). |
| `--fg <col>` | `15` | Text color (in powerline/rainbow modes). |
| `--icon <sym>` | ` ` | Custom icon override. |
| `--format <fn>` | None | Custom Zsh formatter function setting `$REPLY`. |

---

## `git` (Git Working Tree)

Fast, two-phase Git status: instant synchronous branch detection (< 0.1 ms) + non-blocking async dirty checking.

```zsh
git --clean 2 --dirty 3 --ahead 12
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--clean <col>` | `2` (green) | Color when working tree is clean. |
| `--dirty <col>` | `3` (yellow) | Color when working tree has modified, staged, or untracked files. |
| `--ahead <col>` | `12` (blue) | Color when branch is ahead of upstream. |
| `--icon <sym>` | ` ` | Branch icon symbol. |

### Status Badges:
- `+N`: `N` staged changes
- `!N`: `N` unstaged modifications
- `?N`: `N` untracked files
- `⇡N`: Ahead of remote by `N` commits
- `⇣N`: Behind remote by `N` commits
- `xN`: `N` unmerged merge conflicts

---

## `status` (Exit Code)

Command return status and failure indicator.

```zsh
status --hide-zero --color 9
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--hide-zero` | Default | Hides status badge when exit code is 0. |
| `--show-zero` | Off | Explicitly renders `0` in green on success. |
| `--color <col>` | `9` (red) | Color for non-zero exit codes. |
| `--ok <col>` | `10` (green) | Color when exit code is 0 (with `--show-zero`). |

---

## `exec_time` (Execution Duration)

High-precision command duration measured via Zsh's built-in `$EPOCHREALTIME`.

```zsh
exec_time --min 2 --color 11
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--min <N>` | `2` | Minimum duration in seconds before displaying execution time. |
| `--color <col>` | `11` (yellow) | Text/badge color. |

---

## `prompt_char` (Prompt Character)

The active terminal input character. Automatically tracks exit codes and Vi-mode.

```zsh
prompt_char --symbol '❯' --error 9 --vi-cmd '❮'
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--symbol <sym>` | `❯` | Default insert mode prompt symbol. |
| `--error <col>` | `9` (red) | Color when the previous command failed. |
| `--root <sym>` | `#` | Symbol displayed when running as root (`EUID == 0`). |
| `--vi-cmd <sym>` | `❮` | Symbol displayed when in Vi normal/command mode. |
| `--vi-color <col>`| `11` (yellow) | Color when in Vi normal/command mode. |

---

## `venv` (Python Virtual Environment)

Displays active virtual environment from `$VIRTUAL_ENV`, `$CONDA_DEFAULT_ENV`, or `$POETRY_ACTIVE`.

```zsh
venv --color 5
```

---

## `node` (Node.js Version)

Displays Node.js version from `.node-version`, `.nvmrc`, or `$NODE_VERSION`.

```zsh
node --color 2
```

---

## `k8s` (Kubernetes Context)

Displays active Kubernetes context from `$KUBECONFIG` or `~/.kube/config` with zero `kubectl` process spawns.

```zsh
k8s --color 6
```
