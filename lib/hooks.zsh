autoload -Uz add-zsh-hook

typeset -ga _zline_hooks_chpwd=()
typeset -ga _zline_hooks_precmd=()
typeset -ga _zline_hooks_preexec=()
typeset -ga _zline_hooks_zshexit=()
typeset -ga _zline_hooks_pre_render=()
typeset -ga _zline_hooks_post_render=()
typeset -ga _zline_hooks_keymap_select=()
typeset -ga _zline_hooks_line_finish=()

zline_hook() {
  emulate -L zsh
  local action="$1"
  local event="$2"
  local fn="${3:-}"
  local var="_zline_hooks_${event}"

  if (( ! ${(P)+var} )); then
    return 1
  fi

  case "$action" in
    add)
      local -a cur=("${(@P)var}")
      if (( ${cur[(Ie)$fn]} == 0 )); then
        set -A "$var" "${cur[@]}" "$fn"
      fi
      ;;
    remove)
      local -a cur=("${(@P)var}")
      local idx=${cur[(Ie)$fn]}
      if (( idx > 0 )); then
        cur[idx]=()
        set -A "$var" "${cur[@]}"
      fi
      ;;
    run)
      shift 2
      local hook_fn
      for hook_fn in "${(@P)var}"; do
        if (( $+functions[$hook_fn] )); then
          "$hook_fn" "$@"
        fi
      done
      ;;
    *)
      return 1
      ;;
  esac
}

_zline_on_chpwd() {
  zline_hook run chpwd "$@"
}

_zline_on_precmd() {
  typeset -g _zline_last_exit_code=$?
  zline_hook run precmd "$@"
  zline_render
}

_zline_on_preexec() {
  zline_hook run preexec "$@"
}

_zline_on_zshexit() {
  zline_hook run zshexit "$@"
}

TRAPWINCH() {
  if [[ -o interactive ]] && (( $+functions[zle] )); then
    zline_render
    zle reset-prompt 2>/dev/null
  fi
}

_zline_hooks_install() {
  add-zsh-hook chpwd _zline_on_chpwd
  add-zsh-hook precmd _zline_on_precmd
  add-zsh-hook preexec _zline_on_preexec
  add-zsh-hook zshexit _zline_on_zshexit
}

_zline_hooks_uninstall() {
  add-zsh-hook -d chpwd _zline_on_chpwd
  add-zsh-hook -d precmd _zline_on_precmd
  add-zsh-hook -d preexec _zline_on_preexec
  add-zsh-hook -d zshexit _zline_on_zshexit
}
