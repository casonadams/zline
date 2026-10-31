zmodload -F zsh/stat b:zstat 2>/dev/null

typeset -g _zline_k8s_cache_file=""
typeset -g _zline_k8s_cache_ctx=""
typeset -g _zline_k8s_cache_stamp=""

zline_segment_k8s() {
  local -A opts=()
  _zline_std_opts "$@"

  local config_file="${KUBECONFIG:-${HOME}/.kube/config}"
  config_file="${config_file%%:*}"
  [[ -r "$config_file" ]] || { _zline_ret_content=""; return 0; }

  local ctx=""
  _zline_file_stamp "$config_file"
  local stamp="$REPLY"
  if [[ -n "$stamp" && "$stamp" == "$_zline_k8s_cache_stamp" && "$_zline_k8s_cache_file" == "$config_file" ]]; then
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
    _zline_k8s_cache_stamp="$stamp"
    _zline_k8s_cache_file="$config_file"
    _zline_k8s_cache_ctx="$ctx"
  fi

  _zline_segment_emit "$ctx" 6 6 0 "k8s:" $'\u2388 '
}
