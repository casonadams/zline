zline_segment_os() {
  emulate -L zsh
  local -A opts=()
  local -a flags=()
  zparseopts -E -D -A opts -K \
    -text=flags \
    -symbol:=opts -color:=opts -bg:=opts -fg:=opts

  local os_name="linux"
  local sym=""
  local col=""
  local ascii_sym=""

  case "$OSTYPE" in
    darwin*)
      os_name="mac"
      sym=$'\uF179 '
      ascii_sym="mac:"
      col="15"
      ;;
    freebsd*)
      os_name="freebsd"
      sym=$'\uF28F '
      ascii_sym="bsd:"
      col="9"
      ;;
    openbsd*)
      os_name="openbsd"
      sym=$'\uF28F '
      ascii_sym="obsd:"
      col="11"
      ;;
    android*|*termux*)
      os_name="android"
      sym=$'\uF17B '
      ascii_sym="android:"
      col="10"
      ;;
    *)
      # Linux / other
      local dist_id=""
      if [[ -f "/etc/os-release" ]]; then
        local line
        while IFS= read -r line; do
          if [[ "$line" == "ID="* ]]; then
            dist_id="${line#ID=}"
            dist_id="${dist_id//[\"\']}"
            break
          fi
        done < "/etc/os-release" 2>/dev/null
      fi

      case "$dist_id" in
        ubuntu)
          os_name="ubuntu"
          sym=$'\uF31B '
          ascii_sym="ubuntu:"
          col="9"
          ;;
        debian)
          os_name="debian"
          sym=$'\uF306 '
          ascii_sym="debian:"
          col="9"
          ;;
        arch|manjaro|archarm)
          os_name="arch"
          sym=$'\uF303 '
          ascii_sym="arch:"
          col="14"
          ;;
        fedora|rhel|centos|rocky|alma)
          os_name="fedora"
          sym=$'\uF30A '
          ascii_sym="fedora:"
          col="12"
          ;;
        alpine)
          os_name="alpine"
          sym=$'\uF300 '
          ascii_sym="alpine:"
          col="4"
          ;;
        nixos)
          os_name="nixos"
          sym=$'\uF313 '
          ascii_sym="nixos:"
          col="14"
          ;;
        void)
          os_name="void"
          sym=$'\uF32E '
          ascii_sym="void:"
          col="10"
          ;;
        gentoo)
          os_name="gentoo"
          sym=$'\uF30D '
          ascii_sym="gentoo:"
          col="13"
          ;;
        *)
          os_name="linux"
          sym=$'\uF17C '
          ascii_sym="linux:"
          col="15"
          ;;
      esac
      ;;
  esac

  local content=""
  if (( ${flags[(Ie)--text]} > 0 )); then
    content="${os_name}"
  fi

  _zline_ret_content="${content}"
  _zline_ret_fg="${opts[--color]:-$col}"
  _zline_ret_bg="${opts[--bg]:-$col}"

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    _zline_ret_fg="${opts[--fg]:-0}"
  fi

  if [[ -n "${opts[(i)--symbol]}" ]]; then
    _zline_ret_icon="${opts[--symbol]}"
  elif [[ "$_zline_mode" == "ascii" ]]; then
    _zline_ret_icon="${ascii_sym}"
  else
    _zline_ret_icon="${sym}"
  fi
}
