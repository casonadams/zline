# Agent Guidelines for zline

`zline` is an ultra-fast, zero-dependency, pure-Zsh replacement for Powerlevel10k and Starship designed for sub-millisecond synchronous rendering and zero subshell forks.

---

## 1. Documentation Alignment & Synchronization (Mandatory)

Whenever adding, updating, or deprecating features, segment options, presets, color themes, or CLI commands, **all three documentation surfaces must remain strictly aligned and in sync**:

1. **Manual Pages (`man/man1/zline.1`)**:
   - Every registered segment in `lib/render.zsh` (`_zline_registered_segments`) must be documented under `.SH BUILT-IN SEGMENTS`.
   - Every CLI command and preset option must be documented under `.SH CLI COMMANDS` and `.SH PRESETS`.
   - Automated tests (`test/test_man.zsh`, `test/test_slice11.zsh`, `test/test_slice14.zsh`, `test/test_slice15.zsh`) fail if any segment is missing from the man page.

2. **GitHub Documentation (`README.md` and `docs/*.md`)**:
   - `README.md`: Overview, quick start, visual presets, curated color themes, performance benchmarks, and links.
   - `docs/segments.md`: Comprehensive segment option table, default values, and example invocations.
   - `docs/syntax.md`: Array configuration syntax, inline overrides, global styling flags, and CLI command reference.
   - `docs/styling-and-colors.md`: Base16 / Term16 palette definitions, Nerd Font / ASCII modes, and frame/connecting lines.
   - `docs/hooks-and-extensibility.md`: Custom segment authoring and lifecycle hooks (`precmd`, `chpwd`, `keymap_select`).
   - `docs/migrating-from-p10k.md`: Powerlevel10k configuration translation mapping.

3. **Web Documentation & Playground (`www/index.html` and `www/docs.html`)**:
   - `www/docs.html`: Complete CLI command list, presets, themes, and built-in segments list.
   - `www/index.html`: Interactive preview controls, configuration builder flags, and generated code snippet generator.

Never submit changes to functionality or configuration options without updating the corresponding sections across `man/`, `docs/` + `README.md`, and `www/`.

---

## 2. Core Architecture Constraints

- **Strict Zero-Fork Synchronous Path**:
  - No subshells `$(...)` or backticks `` `...` `` allowed on the prompt render path (`lib/render.zsh`, `lib/color.zsh`, `lib/osc.zsh`, and synchronous segment handlers).
  - Use native Zsh builtins, parameter expansions (`${var//search/replace}`, `${var:t}`, `${var:h}`), math evaluations (`$(( ... ))`), and `printf -v`.
  - Static analysis in `test/test_zero_forks.zsh` verifies zero subshell forks on the hot path.

- **Compile Once, Render Microseconds**:
  - All arguments are parsed and tokenized once when `zline init` executes (`zline_compile`).
  - Per-prompt rendering executes pre-compiled function references without `zparseopts` or flag parsing overhead.

- **Base16 / Term16 Palette First**:
  - Standardizes on ANSI colors 0 through 15 so prompts automatically adapt to terminal color schemes without hardcoded RGB hex codes.

- **Non-Blocking Asynchronous Worker**:
  - Potentially slow I/O (such as Git status scans) must be dispatched to the background worker (`lib/worker.zsh`) via FIFOs/pipes. Never block synchronous rendering on slow filesystem operations.

- **100% Pure Zsh**:
  - No compiled C/Rust/Go helper binaries. Must run cleanly on any POSIX system with Zsh >= 5.8 (macOS, Linux, BSD, Alpine/musl, Termux).

---

## 3. Cross-Platform Portability & Test Discipline

- **No Hardcoded Environment Assumptions**:
  - Never hardcode user paths (e.g. `/Users/...` or `/home/...`), usernames, or platform-specific filesystem layouts in tests or specs.
  - In unit tests and specs, use `$HOME`, `$PWD`, or temporary directories created via `mktemp -d`.
  - Account for trailing slashes when referencing `${TMPDIR:-/tmp}`.
  - Tests must pass cleanly on both macOS (`macos-latest`) and Ubuntu Linux (`ubuntu-latest`).

- **Test-Driven Verification**:
  - All 7 specification verification gates must pass:
    ```zsh
    zsh test/verify_all.zsh
    ```
  - Gate 1: AST syntax check (`zsh -n`).
  - Gate 2: POSIX installer & ShellCheck audit (`sh -n install.sh`, `shellcheck install.sh`).
  - Gate 3: ShellSpec BDD suite (`shellspec`).
  - Gate 4: Unit test suite (`zsh test/run_all.zsh`).
  - Gate 5: Latency benchmarks (`zsh benchmark/bench.zsh`).
  - Gate 6: Zero-fork execution audit (`zsh test/test_zero_forks.zsh`).
  - Gate 7: Manual page and segment completeness (`zsh test/test_man.zsh`).

---

## 4. Git & Commit Standards

- Follow Conventional Commits: `<type>(<scope>): <summary>` (e.g., `feat(segments): add cpu load monitoring`, `fix(git): handle detached heads`).
- Release management is automated via `release-please`. Commit messages directly determine version bumps and CHANGELOG entries.
