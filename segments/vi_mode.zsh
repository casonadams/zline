zline_segment_vi_mode() {
  emulate -L zsh
  local -A opts=()
  local -a flags=()
  zparseopts -E -D -A opts -K \
    -normal:=opts -insert:=opts -visual:=opts \
    -color-normal:=opts -color-insert:=opts -color-visual:=opts \
    -hide-insert=flags -icon:=opts -color:=opts -bg:=opts -fg:=opts

  local km="${KEYMAP:-${_zline_vi_mode:-main}}"
  local text=""
  local col=""

  case "$km" in
    vicmd|normal)
      text="${opts[--normal]:-NOR}"
      col="${opts[--color-normal]:-11}"
      ;;
    visual)
      text="${opts[--visual]:-VIS}"
      col="${opts[--color-visual]:-13}"
      ;;
    *)
      if (( ${flags[(Ie)--hide-insert]} > 0 )); then
        _zline_ret_content=""
        return 0
      fi
      text="${opts[--insert]:-INS}"
      col="${opts[--color-insert]:-10}"
      ;;
  esac

  _zline_ret_content="${text}"
  _zline_ret_fg="${opts[--color]:-$col}"
  _zline_ret_bg="${opts[--bg]:-$col}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--icon]}" ]]; then
    _zline_ret_icon="${opts[--icon]}"
  else
    _zline_ret_icon=""
  fi
}
