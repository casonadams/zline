zmodload -F zsh/stat b:zstat 2>/dev/null

typeset -g _zline_k8s_cache_file=""
typeset -g _zline_k8s_cache_ctx=""
typeset -gi _zline_k8s_cache_mtime=0

zline_segment_k8s() {
  local -A opts=()
  zparseopts -E -D -A opts -K \
    -color:=opts -icon:=opts -bg:=opts -fg:=opts

  local config_file="${KUBECONFIG:-${HOME}/.kube/config}"
  config_file="${config_file%%:*}"
  [[ -r "$config_file" ]] || { _zline_ret_content=""; return 0; }

  local -i mtime=0
  if (( $+builtins[zstat] )); then
    zstat -A mtime +mtime "$config_file" 2>/dev/null
  fi

  local ctx=""
  if (( mtime > 0 && mtime == _zline_k8s_cache_mtime )) && [[ "$_zline_k8s_cache_file" == "$config_file" ]]; then
    ctx="$_zline_k8s_cache_ctx"
  else
    local line
    while IFS= read -r line; do
      if [[ "$line" == "current-context:"* ]]; then
        ctx="${line#current-context: }"
        ctx="${ctx//[\'\"]}"
        ctx="${${ctx##*/}%%.*}"
        break
      fi
    done < "$config_file"
    _zline_k8s_cache_mtime=$mtime
    _zline_k8s_cache_file="$config_file"
    _zline_k8s_cache_ctx="$ctx"
  fi

  if [[ -z "$ctx" ]]; then
    _zline_ret_content=""
    return 0
  fi

  _zline_ret_content="${ctx}"
  _zline_ret_fg="${opts[--color]:-6}"
  _zline_ret_bg="${opts[--bg]:-6}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="k8s:"
  else
    _zline_ret_icon=$'\u2388 '
  fi
}
