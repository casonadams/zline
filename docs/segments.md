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
| `--readonly-icon <sym>` | ` ` | Custom icon displayed when the current directory is read-only. |
| `--readonly-color <col>` | `9` (red) | Color applied when the current directory is read-only. |
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
| `--ahead-sym <sym>` | `⇡` | Custom symbol for ahead commit counts. |
| `--behind-sym <sym>` | `⇣` | Custom symbol for behind commit counts. |
| `--submodule` | Off | Badges Git submodules with a submodule indicator. |
| `--stash` | Off | Displays stash entry count badge (`*N`). |
| `--icon <sym>` | ` ` | Branch icon symbol. |

### Status Badges:
- `+N`: `N` staged changes
- `!N`: `N` unstaged modifications
- `?N`: `N` untracked files
- `*N`: `N` stashed states (when `--stash` enabled)
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
| `--precision <N>` | `1` | Decimal precision for execution duration (`1` or `2`). |
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

---

## `time` (Current Time)

Displays current time formatted via `strftime` with zero subprocess forks.

```zsh
time --format "%H:%M:%S" --color 8
```

---

## `jobs` (Background Jobs)

Displays count of active background jobs tracked by `$jobstates`.

```zsh
jobs --color 11
```

---

## `aws` (AWS Profile & Region)

Displays active AWS profile and region from `$AWS_PROFILE` and `$AWS_REGION`.

```zsh
aws --color 3
```

---

## `rust` (Rust Toolchain)

Displays Rust toolchain version from `rust-toolchain`, `rust-toolchain.toml`, or `Cargo.toml`.

```zsh
rust --color 1
```

---

## `golang` (Go Version)

Displays Go version from `go.mod`.

```zsh
golang --color 6
```

---

## `terraform` (Terraform Workspace)

Displays active Terraform workspace from `$TF_WORKSPACE` or `.terraform/environment`.

```zsh
terraform --color 5
```

---

## `docker` (Docker Context)

Displays active Docker context from `$DOCKER_CONTEXT`, `$DOCKER_HOST`, or `~/.docker/config.json`.

```zsh
docker --color 4
```

---

## `package` (Project Version)

Displays project version extracted from `package.json` or `Cargo.toml`.

```zsh
package --color 8
```

---

## `user_host` (SSH & Root Context)

Displays `user@host` only during remote SSH sessions or when root (`EUID == 0`).

```zsh
user_host --color 8 --ssh-color 11 --root-color 9
```

---

## `battery` (Battery Monitoring)

Displays battery level and charging state (reads `/sys/class/power_supply` on Linux, `pmset` on macOS).

```zsh
battery --color 10 --warn 9
```

---

## `ruby` (Ruby Version)

Displays Ruby version from `.ruby-version` or `Gemfile`.

```zsh
ruby --color 1
```

---

## `php` (PHP Version)

Displays PHP version from `.php-version` or `composer.json`.

```zsh
php --color 5
```

---

## `java` (Java Version)

Displays Java version from `.java-version`, `pom.xml`, or `build.gradle`.

```zsh
java --color 3
```

---

## `dotnet` (.NET Version)

Displays .NET version from `global.json` or `*.csproj`.

```zsh
dotnet --color 5
```

---

## `load` (System Load Average)

Displays 1-minute system load average with configurable warning thresholds.

```zsh
load --warn 4.0 --warn-color 9 --color 8
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--warn <val>` | `4.0` | Load threshold that triggers the warning color. |
| `--warn-color <col>` | `9` (red) | Color applied when load exceeds threshold. |
| `--color <col>` | `8` (grey) | Color applied during normal load. |
| `--icon <sym>` | ` ` | Load segment icon. |

---

## `ram` (Memory Utilization)

Displays system memory utilization percentage or capacity with warning alerts.

```zsh
ram --warn 80 --warn-color 9 --color 8
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--warn <pct>` | `80` | Memory percentage threshold that triggers warning color. |
| `--warn-color <col>` | `9` (red) | Color applied when memory utilization exceeds threshold. |
| `--color <col>` | `8` (grey) | Color applied during normal memory utilization. |
| `--icon <sym>` | `󰍛 ` | Memory segment icon. |

---

## `nix_shell` (Nix Environment)

Displays active Nix development shell status (`$IN_NIX_SHELL` or `$name`).

```zsh
nix_shell --color 14
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--color <col>` | `14` (cyan) | Foreground text / icon color. |
| `--bg <col>` | `14` | Background block color in Powerline/Rainbow modes. |
| `--icon <sym>` | ` ` | Nix segment icon (`nix:` in ASCII mode). |

---

## `direnv` (Direnv Environment)

Displays active Direnv environment indicator from `$DIRENV_DIR`.

```zsh
direnv --color 11
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--color <col>` | `11` (yellow) | Foreground text / icon color. |
| `--bg <col>` | `11` | Background block color in Powerline/Rainbow modes. |
| `--icon <sym>` | `▼ ` | Direnv segment icon (`direnv:` in ASCII mode). |

---

## `lua` (Lua Runtime)

Displays active Lua version from `.lua-version`, `.tool-versions`, or project files.

```zsh
lua --color 4
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--color <col>` | `4` (blue) | Foreground text / icon color. |
| `--bg <col>` | `4` | Background block color in Powerline/Rainbow modes. |
| `--icon <sym>` | ` ` | Lua segment icon (`lua:` in ASCII mode). |

---

## `zig` (Zig Toolchain)

Displays active Zig version from `.zigversion`, `.tool-versions`, or `build.zig`.

```zsh
zig --color 3
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--color <col>` | `3` (yellow) | Foreground text / icon color. |
| `--bg <col>` | `3` | Background block color in Powerline/Rainbow modes. |
| `--icon <sym>` | `↯ ` | Zig segment icon (`zig:` in ASCII mode). |

---

## `bun` (Bun Runtime)

Displays active Bun runtime version from `.tool-versions` or detects `bun.lockb` / `bunfig.toml`.

```zsh
bun --color 15
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--color <col>` | `15` (white) | Foreground text / icon color. |
| `--bg <col>` | `15` | Background block color in Powerline/Rainbow modes. |
| `--icon <sym>` | `🥟 ` | Bun segment icon (`bun:` in ASCII mode). |

---

## `deno` (Deno Runtime)

Displays active Deno runtime version from `.tool-versions` or detects `deno.json` / `deno.lock`.

```zsh
deno --color 10
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--color <col>` | `10` (green) | Foreground text / icon color. |
| `--bg <col>` | `10` | Background block color in Powerline/Rainbow modes. |
| `--icon <sym>` | `🦕 ` | Deno segment icon (`deno:` in ASCII mode). |

---

## `vi_mode` (Modal Editing Indicator)

Displays current ZLE keymap state (`NORMAL`, `INSERT`, `VISUAL`).

```zsh
vi_mode --normal NOR --insert INS --hide-insert
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--normal <str>` | `NOR` | Label displayed during Normal (`vicmd`) mode. |
| `--insert <str>` | `INS` | Label displayed during Insert (`viins`/`main`) mode. |
| `--visual <str>` | `VIS` | Label displayed during Visual mode. |
| `--color-normal <col>` | `11` (yellow) | Color applied during Normal mode. |
| `--color-insert <col>` | `10` (green) | Color applied during Insert mode. |
| `--color-visual <col>` | `13` (magenta) | Color applied during Visual mode. |
| `--hide-insert` | `false` | When set, hides the segment during Insert mode. |

---

## `gcp` (Google Cloud Platform)

Displays active Google Cloud project from environment variables or active `gcloud` configuration.

```zsh
gcp --color 12
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--color <col>` | `12` (bright-blue) | Foreground text / icon color. |
| `--bg <col>` | `12` | Background block color in Powerline/Rainbow modes. |
| `--icon <sym>` | `󱇶 ` | GCP segment icon (`gcp:` in ASCII mode). |

---

## `azure` (Microsoft Azure)

Displays active Azure subscription from environment variables or `azureProfile.json`.

```zsh
azure --color 14
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--color <col>` | `14` (cyan) | Foreground text / icon color. |
| `--bg <col>` | `14` | Background block color in Powerline/Rainbow modes. |
| `--icon <sym>` | `󰠅 ` | Azure segment icon (`az:` in ASCII mode). |

---

## `elixir` (Elixir Runtime)

Displays active Elixir version from `.tool-versions` or detects `mix.exs`.

```zsh
elixir --color 5
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--color <col>` | `5` (magenta) | Foreground text / icon color. |
| `--bg <col>` | `5` | Background block color in Powerline/Rainbow modes. |
| `--icon <sym>` | ` ` | Elixir segment icon (`ex:` in ASCII mode). |

---

## `os` (Operating System / Distro Badge)

Displays host operating system or Linux distribution icon and optional name.

```zsh
os --text
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--text` | `false` | Displays OS or distribution name alongside icon. |
| `--symbol <sym>` | Auto-detected | Custom OS symbol override. |
| `--color <col>` | Auto-detected | Custom foreground color override. |
| `--bg <col>` | Auto-detected | Background block color in Powerline/Rainbow modes. |

---

## `container` (Container & Sandbox Indicator)

Detects containerized environments (Docker, Podman, WSL, Flatpak, Snap).

```zsh
container --color 14
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--color <col>` | `14` (cyan) | Foreground text / icon color. |
| `--bg <col>` | `14` | Background block color in Powerline/Rainbow modes. |
| `--icon <sym>` | `⬢ ` | Container segment icon (`box:` in ASCII mode). |

---

## `shlvl` (Shell Nesting Depth)

Displays a visual warning when shell nesting depth exceeds a threshold.

```zsh
shlvl --threshold 2 --warn 9
```

| Flag | Default | Description |
| :--- | :--- | :--- |
| `--threshold <int>` | `2` | Minimum `$SHLVL` required to display segment. |
| `--color <col>` | `11` (yellow) | Color applied at initial threshold. |
| `--warn <col>` | `9` (red) | Color applied at deep nesting levels (`>= threshold + 1`). |
| `--icon <sym>` | `↕ ` | Shell depth icon (`shlvl:` in ASCII mode). |

---

## Universal `.tool-versions` Detection

Language runtime segments (`node`, `rust`, `golang`, `ruby`, `php`, `java`, `dotnet`, `venv`, `lua`, `zig`, `bun`, `deno`, `elixir`) automatically resolve versions defined in `.tool-versions` (used by `asdf`, `mise`, and `rtx`) in pure Zsh without executing external subshells.
