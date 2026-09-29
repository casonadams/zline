typeset -g ZLINE_VERSION="0.1.0"
typeset -g ZLINE_DIR="${${(%):-%x}:A:h}"

typeset -ga zline_left=()
typeset -ga zline_right=()

typeset -gU manpath
manpath=("${ZLINE_DIR}/man" "${manpath[@]}")

typeset -gU fpath
fpath=("${ZLINE_DIR}/completion" "${fpath[@]}")

source "${ZLINE_DIR}/lib/color.zsh"
source "${ZLINE_DIR}/lib/hooks.zsh"
source "${ZLINE_DIR}/lib/render.zsh"
source "${ZLINE_DIR}/lib/worker.zsh"
source "${ZLINE_DIR}/lib/osc.zsh"
source "${ZLINE_DIR}/lib/transient.zsh"
source "${ZLINE_DIR}/lib/instant.zsh"
source "${ZLINE_DIR}/lib/doctor.zsh"
source "${ZLINE_DIR}/lib/configure.zsh"
source "${ZLINE_DIR}/lib/compile.zsh"
source "${ZLINE_DIR}/lib/migrate.zsh"
source "${ZLINE_DIR}/lib/title.zsh"
source "${ZLINE_DIR}/lib/notify.zsh"
source "${ZLINE_DIR}/lib/update.zsh"
source "${ZLINE_DIR}/lib/compare.zsh"

for _zline_seg in "${ZLINE_DIR}"/segments/*.zsh(N); do
  source "$_zline_seg"
done
unset _zline_seg

zline() {
  emulate -L zsh
  local cmd="$1"
  shift

  case "$cmd" in
    preset)
      local preset_name="$1"
      shift
      if [[ "$preset_name" == "list" ]]; then
        print -P "%F{14}%BAvailable zline Presets:%b%f\n"
        local f
        for f in "${ZLINE_DIR}"/themes/*.zsh(N); do
          local name="${f:t:r}"
          local desc="Custom preset"
          case "$name" in
            powerline) desc="Classic background blocks joined by Powerline arrows" ;;
            lean) desc="Modern, flat, space-separated layout" ;;
            rainbow) desc="Vivid high-contrast colored blocks" ;;
            pure) desc="Minimalist two-line layout" ;;
          esac
          local name_pad="${(r:12:)name}"
          print -P "  %F{10}%B${name_pad}%b%f : ${desc}"
        done
        return 0
      elif [[ "$preset_name" == "show" ]]; then
        local target="${1:-powerline}"
        local tf="${ZLINE_DIR}/themes/${target}.zsh"
        if [[ -r "$tf" ]]; then
          cat "$tf"
        else
          print -u2 -r -- "zline: preset not found: $target"
          return 1
        fi
        return 0
      fi
      local theme_file="${ZLINE_DIR}/themes/${preset_name}.zsh"
      if [[ -r "$theme_file" ]]; then
        _zline_connect_char=""
        source "$theme_file"
      else
        print -u2 -r -- "zline: unknown preset: $preset_name"
        return 1
      fi
      while (( $# > 0 )); do
        case "$1" in
          --transient) _zline_transient=1 ;;
          --transient-dir) _zline_transient=1; _zline_transient_show_dir=1 ;;
          --no-transient) _zline_transient=0; _zline_transient_show_dir=0 ;;
          --no-osc) _zline_osc=0 ;;
          --no-instant) _zline_instant_enabled=0 ;;
          --ascii) _zline_mode="ascii" ;;
          --nerdfont) _zline_mode="nerdfont" ;;
          --no-icons) _zline_icons=0 ;;
          --icons) _zline_icons=1 ;;
          --frame) shift; _zline_frame="$1" ;;
          --frame-shape) shift; _zline_frame_shape="$1" ;;
          --title) _zline_title_enabled=1 ;;
          --no-title) _zline_title_enabled=0 ;;
          --notify)
            _zline_notify_enabled=1
            if [[ -n "$2" && "$2" == <-> ]]; then
              shift
              _zline_notify_threshold="$1"
            fi
            ;;
          --no-notify) _zline_notify_enabled=0 ;;
          --hyperlinks) _zline_osc_hyperlinks=1 ;;
          --no-hyperlinks) _zline_osc_hyperlinks=0 ;;
          --connect) shift; _zline_connect_char="$1" ;;
          --connect-color) shift; _zline_connect_color="$1" ;;
          --rprompt-line) shift; _zline_rprompt_line="$1" ;;
        esac
        shift
      done
      ;;
    style)
      local style_name="$1"
      shift
      _zline_style="$style_name"
      while (( $# > 0 )); do
        case "$1" in
          --transient)
            _zline_transient=1
            ;;
          --transient-dir)
            _zline_transient=1
            _zline_transient_show_dir=1
            ;;
          --no-transient)
            _zline_transient=0
            _zline_transient_show_dir=0
            ;;
          --no-osc)
            _zline_osc=0
            ;;
          --no-instant)
            _zline_instant_enabled=0
            ;;
          --transient-symbol)
            shift
            _zline_transient_symbol="$1"
            ;;
          --transient-color)
            shift
            _zline_transient_color="$1"
            ;;
          --ascii)
            _zline_mode="ascii"
            ;;
          --nerdfont)
            _zline_mode="nerdfont"
            ;;
          --no-icons)
            _zline_icons=0
            ;;
          --icons)
            _zline_icons=1
            ;;
          --title)
            _zline_title_enabled=1
            ;;
          --no-title)
            _zline_title_enabled=0
            ;;
          --notify)
            _zline_notify_enabled=1
            if [[ -n "$2" && "$2" == <-> ]]; then
              shift
              _zline_notify_threshold="$1"
            fi
            ;;
          --no-notify)
            _zline_notify_enabled=0
            ;;
          --title-format)
            shift
            _zline_title_format="$1"
            ;;
          --hyperlinks)
            _zline_osc_hyperlinks=1
            ;;
          --no-hyperlinks)
            _zline_osc_hyperlinks=0
            ;;
          --frame)
            shift
            _zline_frame="$1"
            ;;
          --frame-shape)
            shift
            _zline_frame_shape="$1"
            ;;
          --connect)
            shift
            case "$1" in
              solid) _zline_connect_char="─" ;;
              dashed) _zline_connect_char="┄" ;;
              dotted) _zline_connect_char="┈" ;;
              none) _zline_connect_char="" ;;
              *) _zline_connect_char="$1" ;;
            esac
            ;;
          --connect-color)
            shift
            _zline_connect_color="$1"
            ;;
          --rprompt-line)
            shift
            _zline_rprompt_line="$1"
            ;;
        esac
        shift
      done
      ;;
    init)
      setopt prompt_subst
      setopt prompt_percent
      zline_compile
      _zline_hooks_install
      _zline_worker_start
      _zline_instant_restore
      _zline_transient_install
      zline_render
      _zline_instant_save
      ;;
    bench)
      if [[ "$1" == "--startup" ]]; then
        shift
        zsh "${ZLINE_DIR}/benchmark/startup.zsh" "$@"
        return 0
      fi
      if [[ "$1" == "--profile" ]]; then
        shift
        local -i iters="${1:-500}"
        zmodload -F zsh/datetime p:EPOCHREALTIME 2>/dev/null
        print -P "%F{14}%B============================================================%b%f"
        print -P "%F{15}%B              zline Per-Segment Micro-Profile               %b%f"
        print -P "%F{14}%B============================================================%b%f\n"
        printf "%-20s %10s %12s %12s\n" "Segment" "Runs" "Total Time" "Per Op"
        printf "%-20s %10s %12s %12s\n" "--------------------" "----------" "------------" "------------"
        local -a segs=("${_zline_compiled_left_names[@]}" "${_zline_compiled_right_names[@]}")
        local s
        for s in "${(u)segs[@]}"; do
          [[ "$s" == "newline" ]] && continue
          local fn="zline_segment_${s}"
          if (( $+functions[$fn] )); then
            local -F t0=$EPOCHREALTIME
            local -i i
            for (( i = 1; i <= iters; i++ )); do
              "$fn"
            done
            local -F t1=$EPOCHREALTIME
            local -F total_ms=$(( (t1 - t0) * 1000.0 ))
            local -F per_us=$(( total_ms * 1000.0 / iters ))
            printf "%-20s %10d %10.2f ms %10.1f µs\n" "$s" "$iters" "$total_ms" "$per_us"
          fi
        done
        print -P "\n%F{14}%B============================================================%b%f"
        return 0
      fi
      local -i iters="${1:-1000}"
      zmodload zsh/datetime
      local t0=$EPOCHREALTIME
      local -i i
      for (( i = 1; i <= iters; i++ )); do
        zline_render
      done
      local t1=$EPOCHREALTIME
      local total_ms=$(( (t1 - t0) * 1000.0 ))
      local per_ms=$(( total_ms / iters ))
      printf "zline bench: %d iterations in %.2f ms (%.4f ms/render)\n" "$iters" "$total_ms" "$per_ms"
      ;;
    version)
      print -r -- "zline v${ZLINE_VERSION}"
      ;;
    doctor)
      zline_doctor "$@"
      ;;
    configure)
      zline_configure "$@"
      ;;
    compile)
      zline_compile_all
      ;;
    clean)
      zline_clean_compiled
      ;;
    migrate)
      zline_migrate "$@"
      ;;
    compare)
      zline_compare "$@"
      ;;
    update)
      zline_update "$@"
      ;;
    notify)
      _zline_notify_cmd "$@"
      ;;
    *)
      print -u2 -r -- "zline: unknown command: $cmd"
      return 1
      ;;
  esac
}
