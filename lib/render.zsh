typeset -g _zline_style="lean"
typeset -g _zline_mode="nerdfont"
typeset -g _zline_sep_left=""
typeset -g _zline_sep_right=""
typeset -g _zline_sep_left_soft=""
typeset -g _zline_sep_right_soft=""

typeset -ga _zline_compiled_left_names=()
typeset -ga _zline_compiled_left_args=()
typeset -ga _zline_compiled_right_names=()
typeset -ga _zline_compiled_right_args=()

typeset -gA _zline_registered_segments=(
  dir 1
  git 1
  status 1
  exec_time 1
  prompt_char 1
  venv 1
  k8s 1
  node 1
  time 1
  jobs 1
  aws 1
  rust 1
  golang 1
  terraform 1
  docker 1
  package 1
  user_host 1
  battery 1
  ruby 1
  php 1
  java 1
  dotnet 1
  load 1
  ram 1
  nix_shell 1
  direnv 1
  lua 1
  zig 1
  bun 1
  deno 1
  vi_mode 1
  gcp 1
  azure 1
  elixir 1
  os 1
  container 1
  shlvl 1
  crystal 1
  haskell 1
  scala 1
  kotlin 1
  swift 1
  dart 1
  julia 1
  ocaml 1
  helm 1
  pulumi 1
  cmake 1
  newline 1
)

_zline_read_tool_version() {
  emulate -L zsh
  local tool="$1"
  [[ -f ".tool-versions" ]] || { REPLY=""; return 1; }
  local line
  while IFS= read -r line; do
    if [[ "$line" == "${tool} "* ]]; then
      local ver="${line#${tool} }"
      REPLY="${ver%% *}"
      return 0
    fi
  done < ".tool-versions" 2>/dev/null
  REPLY=""
  return 1
}

typeset -g _zline_connect_char=""
typeset -g _zline_connect_color="8"
typeset -gi _zline_rprompt_line=1

_zline_visual_len() {
  local str="$1"
  local -i low=0 high=256 mid
  while (( low < high )); do
    (( mid = (low + high + 1) / 2 ))
    if [[ "${(%):-${str}%${mid}(l.1.0)}" == *1 ]]; then
      low=$mid
    else
      high=$(( mid - 1 ))
    fi
  done
  REPLY=$low
}

_zline_set_style_separators() {
  case "$_zline_style" in
    powerline|rainbow)
      if [[ "$_zline_mode" == "ascii" ]]; then
        _zline_sep_left=">"
        _zline_sep_right="<"
        _zline_sep_left_soft="|"
        _zline_sep_right_soft="|"
      else
        _zline_sep_left=$'\uE0B0'
        _zline_sep_right=$'\uE0B2'
        _zline_sep_left_soft=$'\uE0B1'
        _zline_sep_right_soft=$'\uE0B3'
      fi
      ;;
    *)
      _zline_sep_left=" "
      _zline_sep_right=" "
      _zline_sep_left_soft=" "
      _zline_sep_right_soft=" "
      ;;
  esac
}

_zline_compile_tokens() {
  emulate -L zsh
  local side="$1"
  shift
  local -a items=("$@")
  local -a names=()
  local -a args=()
  local cur_name=""
  local cur_args=""
  local item

  for item in "${items[@]}"; do
    if [[ "$item" == *" "* ]]; then
      if [[ -n "$cur_name" ]]; then
        names+=("$cur_name")
        args+=("${cur_args# }")
        cur_name=""
        cur_args=""
      fi
      local s_name="${item%% *}"
      local s_arg="${item#* }"
      names+=("$s_name")
      args+=("$s_arg")
      continue
    fi

    if [[ -n "${_zline_registered_segments[$item]}" || $+functions[zline_segment_${item}] == 1 ]]; then
      if [[ -n "$cur_name" ]]; then
        names+=("$cur_name")
        args+=("${cur_args# }")
        cur_args=""
      fi
      cur_name="$item"
    else
      cur_args+=" $item"
    fi
  done

  if [[ -n "$cur_name" ]]; then
    names+=("$cur_name")
    args+=("${cur_args# }")
  fi

  if [[ "$side" == "left" ]]; then
    _zline_compiled_left_names=("${names[@]}")
    _zline_compiled_left_args=("${args[@]}")
  else
    _zline_compiled_right_names=("${names[@]}")
    _zline_compiled_right_args=("${args[@]}")
  fi
}

zline_compile() {
  emulate -L zsh
  _zline_set_style_separators
  _zline_compile_tokens "left" "${zline_left[@]}"
  _zline_compile_tokens "right" "${zline_right[@]}"
}

_zline_render_left_segment_lean() {
  local icon="$1"
  local content="$2"
  local fg="$3"

  local fg_code=""
  if [[ -n "$fg" ]]; then
    _zline_fg "$fg"
    fg_code="$REPLY"
  fi

  REPLY=""
  if [[ -n "$icon" ]]; then
    REPLY+="${fg_code}${icon}%f"
    [[ -n "$content" ]] && REPLY+=" "
  fi
  if [[ -n "$content" ]]; then
    REPLY+="${fg_code}${content}%f"
  fi
}

_zline_render_left_segment_powerline() {
  local icon="$1"
  local content="$2"
  local fg="$3"
  local bg="$4"
  local last_bg="$5"

  local out=""
  local fg_code=""
  local bg_code=""
  _zline_fg "${fg:-7}"
  fg_code="$REPLY"
  _zline_bg "${bg:-0}"
  bg_code="$REPLY"

  if [[ "$last_bg" != "none" ]]; then
    local sep_fg=""
    local sep_bg=""
    _zline_fg "$last_bg"
    sep_fg="$REPLY"
    _zline_bg "$bg"
    sep_bg="$REPLY"
    out+="${sep_bg}${sep_fg}${_zline_sep_left}%f"
  fi

  out+="${bg_code}${fg_code} "
  [[ -n "$icon" ]] && out+="${icon} "
  out+="${content} %f"
  REPLY="$out"
}

_zline_render_left() {
  emulate -L zsh
  local out=""
  local last_bg="none"
  local count=${#_zline_compiled_left_names}
  local -i i

  local frame_top=""
  local frame_bot=""
  if [[ "$_zline_frame" == "left" || "$_zline_frame" == "full" ]]; then
    if [[ "$_zline_mode" == "ascii" ]]; then
      frame_top="+- "
      frame_bot="+- "
    else
      frame_top="%F{8}"$'\u256D\u2500'"%f "
      frame_bot="%F{8}"$'\u2570\u2500'"%f "
    fi
    out+="$frame_top"
  fi

  for (( i = 1; i <= count; i++ )); do
    local name="${_zline_compiled_left_names[i]}"
    local raw_args="${_zline_compiled_left_args[i]}"

    if [[ "$name" == "newline" ]]; then
      if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
        if [[ "$last_bg" != "none" ]]; then
          local end_fg=""
          _zline_fg "$last_bg"
          end_fg="$REPLY"
          out+="%k${end_fg}${_zline_sep_left}%f"
          last_bg="none"
        fi
      fi
      out+=$'\n'
      [[ -n "$frame_bot" ]] && out+="$frame_bot"
      continue
    fi

    typeset -g _zline_ret_content=""
    typeset -g _zline_ret_fg=""
    typeset -g _zline_ret_bg=""
    typeset -g _zline_ret_icon=""

    if (( $+functions[zline_segment_${name}] )); then
      "zline_segment_${name}" ${(z)raw_args}
    fi

    if [[ -z "$_zline_ret_content" && -z "$_zline_ret_icon" ]]; then
      continue
    fi

    if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
      local seg_bg="${_zline_ret_bg:-0}"
      _zline_render_left_segment_powerline "$_zline_ret_icon" "$_zline_ret_content" "$_zline_ret_fg" "$seg_bg" "$last_bg"
      out+="$REPLY"
      last_bg="$seg_bg"
    else
      _zline_render_left_segment_lean "$_zline_ret_icon" "$_zline_ret_content" "$_zline_ret_fg"
      [[ -n "$out" && "$out" != *$'\n' ]] && out+=" "
      out+="$REPLY"
    fi
  done

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    if [[ "$last_bg" != "none" ]]; then
      local end_fg=""
      _zline_fg "$last_bg"
      end_fg="$REPLY"
      out+="%k${end_fg}${_zline_sep_left}%f "
    fi
  else
    [[ -n "$out" && "$out" != *$'\n' && "$out" != *" " ]] && out+=" "
  fi

  REPLY="$out"
}

_zline_render_right_segment_powerline() {
  local icon="$1"
  local content="$2"
  local fg="$3"
  local bg="$4"
  local last_bg="$5"

  local out=""
  local fg_code=""
  local bg_code=""
  local sep_fg=""
  local sep_bg=""
  _zline_fg "${fg:-7}"
  fg_code="$REPLY"
  _zline_bg "${bg:-0}"
  bg_code="$REPLY"

  _zline_fg "$bg"
  sep_fg="$REPLY"
  if [[ "$last_bg" == "none" ]]; then
    sep_bg="%k"
  else
    _zline_bg "$last_bg"
    sep_bg="$REPLY"
  fi

  out+="${sep_bg}${sep_fg}${_zline_sep_right}%f"
  out+="${bg_code}${fg_code} "
  [[ -n "$icon" ]] && out+="${icon} "
  out+="${content} %f"
  REPLY="$out"
}

_zline_render_right() {
  emulate -L zsh
  local out=""
  local last_bg="none"
  local count=${#_zline_compiled_right_names}
  local -i i

  for (( i = 1; i <= count; i++ )); do
    local name="${_zline_compiled_right_names[i]}"
    local raw_args="${_zline_compiled_right_args[i]}"

    typeset -g _zline_ret_content=""
    typeset -g _zline_ret_fg=""
    typeset -g _zline_ret_bg=""
    typeset -g _zline_ret_icon=""

    if (( $+functions[zline_segment_${name}] )); then
      "zline_segment_${name}" ${(z)raw_args}
    fi

    if [[ -z "$_zline_ret_content" && -z "$_zline_ret_icon" ]]; then
      continue
    fi

    if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
      local seg_bg="${_zline_ret_bg:-0}"
      _zline_render_right_segment_powerline "$_zline_ret_icon" "$_zline_ret_content" "$_zline_ret_fg" "$seg_bg" "$last_bg"
      out+="$REPLY"
      last_bg="$seg_bg"
    else
      _zline_render_left_segment_lean "$_zline_ret_icon" "$_zline_ret_content" "$_zline_ret_fg"
      [[ -n "$out" ]] && out+=" "
      out+="$REPLY"
    fi
  done

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    [[ -n "$out" ]] && out+="%k"
  fi

  REPLY="$out"
}

zline_render() {
  emulate -L zsh
  zline_hook run pre_render
  _zline_render_left
  local left_body="$REPLY"
  _zline_render_right
  local right_body="$REPLY"

  if [[ -n "$right_body" && -n "$COLUMNS" && $COLUMNS -gt 0 ]]; then
    local left_top="${left_body%%$'\n'*}"
    _zline_visual_len "$left_top"
    local -i left_len=$REPLY
    _zline_visual_len "$right_body"
    local -i right_len=$REPLY

    local frame_end=""
    if [[ "$_zline_frame" == "full" ]]; then
      if [[ "$_zline_mode" == "ascii" ]]; then
        frame_end=" -+"
      else
        frame_end=" %F{8}"$'\u2500\u256E'"%f"
      fi
      right_body="${right_body}${frame_end}"
      _zline_visual_len "$right_body"
      right_len=$REPLY
    fi

    if (( _zline_rprompt_line == 1 )) && [[ "$left_body" == *$'\n'* ]]; then
      local -i rem=$(( COLUMNS - left_len - right_len - 2 ))
      if (( rem > 2 )); then
        local fill_char="${_zline_connect_char:- }"
        local -a fill_chars=()
        local -i fi
        for (( fi = 1; fi <= rem; fi++ )); do
          fill_chars+="$fill_char"
        done
        local filler="${(j::)fill_chars}"
        local left_bot="${left_body#*$'\n'}"
        left_body="${left_top} %F{${_zline_connect_color}}${filler}%f ${right_body}"$'\n'"${left_bot}"
        right_body=""
      fi
    elif (( left_len + right_len + 2 >= COLUMNS )); then
      right_body=""
    fi
  fi

  _zline_osc_prompt_prefix
  local osc_pre="$REPLY"
  _zline_osc_prompt_suffix
  local osc_suf="$REPLY"
  PROMPT="${osc_pre}${left_body}${osc_suf}"

  RPROMPT="$right_body"
  zline_hook run post_render
}
