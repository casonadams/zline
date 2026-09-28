typeset -g ZLINE_VERSION="0.1.0"
typeset -g ZLINE_DIR="${${(%):-%x}:A:h}"

typeset -ga zline_left=()
typeset -ga zline_right=()

typeset -gU manpath
manpath=("${ZLINE_DIR}/man" "${manpath[@]}")

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

for _zline_seg in "${ZLINE_DIR}"/segments/*.zsh(N); do
  source "$_zline_seg"
done
unset _zline_seg

zline() {
  local cmd="$1"
  shift

  case "$cmd" in
    preset)
      local preset_name="$1"
      shift
      local theme_file="${ZLINE_DIR}/themes/${preset_name}.zsh"
      if [[ -r "$theme_file" ]]; then
        source "$theme_file"
      else
        print -u2 -r -- "zline: unknown preset: $preset_name"
        return 1
      fi
      while (( $# > 0 )); do
        case "$1" in
          --transient) _zline_transient=1 ;;
          --no-transient) _zline_transient=0 ;;
          --no-osc) _zline_osc=0 ;;
          --no-instant) _zline_instant_enabled=0 ;;
          --ascii) _zline_mode="ascii" ;;
          --nerdfont) _zline_mode="nerdfont" ;;
          --frame) shift; _zline_frame="$1" ;;
          --title) _zline_title_enabled=1 ;;
          --no-title) _zline_title_enabled=0 ;;
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
          --no-transient)
            _zline_transient=0
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
          --title)
            _zline_title_enabled=1
            ;;
          --no-title)
            _zline_title_enabled=0
            ;;
          --title-format)
            shift
            _zline_title_format="$1"
            ;;
          --frame)
            shift
            _zline_frame="$1"
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
    *)
      print -u2 -r -- "zline: unknown command: $cmd"
      return 1
      ;;
  esac
}
