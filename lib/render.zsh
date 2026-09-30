typeset -g _zline_style="lean"
typeset -g _zline_mode="nerdfont"
typeset -g _zline_sep_left=""
typeset -g _zline_sep_right=""
typeset -g _zline_sep_left_soft=""
typeset -g _zline_sep_right_soft=""
typeset -gi _zline_icons=1

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
  clojure 1
  erlang 1
  perl 1
  r 1
  solidity 1
  mise 1
  jj 1
  meson 1
  bazel 1
  text 1
  newline 1
)

_zline_find_up() {
  emulate -L zsh
  local cur="$PWD"
  local target
  while [[ "$cur" != "/" && -n "$cur" ]]; do
    for target in "$@"; do
      if [[ -f "${cur}/${target}" ]]; then
        REPLY="${cur}/${target}"
        return 0
      fi
    done
    [[ -e "${cur}/.git" ]] && break
    cur="${cur:h}"
  done
  REPLY=""
  return 1
}

_zline_read_tool_version() {
  emulate -L zsh
  local tool="$1"
  _zline_find_up ".tool-versions" || { REPLY=""; return 1; }
  local tv_file="$REPLY"
  local line
  while IFS= read -r line; do
    if [[ "$line" == "${tool} "* ]]; then
      local ver="${line#${tool} }"
      REPLY="${ver%% *}"
      return 0
    fi
  done < "$tv_file" 2>/dev/null
  REPLY=""
  return 1
}

typeset -g _zline_connect_char=""
typeset -g _zline_connect_color="8"
typeset -gi _zline_rprompt_line=1
typeset -g _zline_frame_shape="rounded"

_zline_visual_len() {
  local s="$1"
  [[ -z "$s" ]] && { REPLY=0; return 0; }
  if [[ "$s" != *[%$'\e']* ]]; then
    REPLY=${#${(m)s}}
    return 0
  fi
  setopt localoptions extended_glob
  s="${s//\%\{[^\%]#%\}/}"
  s="${s//\%[FK]\{[^\}]#\}/}"
  s="${s//\%[fkbuUsS]/}"
  s="${(%)s}"
  local esc=$'\e'
  s="${s//${esc}\[[0-9;]#([a-zA-Z]|~)/}"
  s="${s//${esc}\]*($'\a'|${esc}\\\\)/}"
  REPLY=${#${(m)s}}
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
  local -i expect_val=0
  local item

  for item in "${items[@]}"; do
    local first_word="${item%% *}"
    if (( expect_val == 0 )) && [[ -n "${_zline_registered_segments[$first_word]}" || $+functions[zline_segment_${first_word}] == 1 ]]; then
      if [[ -n "$cur_name" ]]; then
        names+=("$cur_name")
        args+=("${cur_args# }")
        cur_name=""
        cur_args=""
      fi
      if [[ "$item" == *" "* ]]; then
        names+=("$first_word")
        args+=("${item#* }")
      else
        cur_name="$item"
      fi
    else
      cur_args+=" ${(q)item}"
      if (( expect_val == 1 )); then
        expect_val=0
      elif [[ "$item" == --* && "$item" != *=* ]]; then
        case "$item" in
          --submodule|--ignore-submodules|--text|--hide-zero|--show-zero|--signal|--always|--hide-insert)
            expect_val=0
            ;;
          *)
            expect_val=1
            ;;
        esac
      fi
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

  local seg
  for seg in "${_zline_compiled_left_names[@]}" "${_zline_compiled_right_names[@]}"; do
    [[ "$seg" == "newline" ]] && continue
    if (( $+functions[_zline_load_segment] )); then
      _zline_load_segment "$seg"
    fi
  done
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
    elif [[ "$_zline_frame_shape" == "sharp" ]]; then
      frame_top="%F{8}"$'\u250C\u2500'"%f "
      frame_bot="%F{8}"$'\u2514\u2500'"%f "
    elif [[ "$_zline_frame_shape" == "double" ]]; then
      frame_top="%F{8}"$'\u2554\u2550'"%f "
      frame_bot="%F{8}"$'\u255A\u2550'"%f "
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

    local -a s_args=()
    [[ -n "$raw_args" ]] && s_args=( "${(@Q)${(@z)raw_args}}" )
    local -A u_opts=()
    if [[ "$raw_args" == *--(prefix|suffix|format)* ]]; then
      () {
        set -- "$@"
        zparseopts -D -E -A u_opts -K -prefix:=u_opts -suffix:=u_opts -format:=u_opts 2>/dev/null
        s_args=( "$@" )
      } "${s_args[@]}"
    fi

    (( ! $+functions[zline_segment_${name}] && $+functions[_zline_load_segment] )) && _zline_load_segment "$name"
    if (( $+functions[zline_segment_${name}] )); then
      "zline_segment_${name}" "${s_args[@]}"
    fi

    if (( _zline_icons == 0 )); then
      if (( ${s_args[(Ie)--icon]} == 0 )); then
        _zline_ret_icon=""
      fi
    fi
    if [[ -z "$_zline_ret_content" && -z "$_zline_ret_icon" ]]; then
      continue
    fi

    if [[ -n "$_zline_ret_content" ]]; then
      if [[ -n "${u_opts[--prefix]}" ]]; then
        _zline_ret_content="${u_opts[--prefix]}${_zline_ret_content}"
      fi
      if [[ -n "${u_opts[--suffix]}" ]]; then
        _zline_ret_content="${_zline_ret_content}${u_opts[--suffix]}"
      fi
      local u_fmt="${u_opts[--format]}"
      if [[ -n "$u_fmt" && $+functions[$u_fmt] -eq 1 ]]; then
        "$u_fmt" "$_zline_ret_content"
        _zline_ret_content="$REPLY"
      fi
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
  local -i max_w="${1:-0}"
  local count=${#_zline_compiled_right_names}
  local -i i

  local -a r_icons=()
  local -a r_contents=()
  local -a r_fgs=()
  local -a r_bgs=()
  local out=""
  local last_bg="none"

  for (( i = 1; i <= count; i++ )); do
    local name="${_zline_compiled_right_names[i]}"
    local raw_args="${_zline_compiled_right_args[i]}"

    typeset -g _zline_ret_content="" _zline_ret_fg="" _zline_ret_bg="" _zline_ret_icon=""
    local -a s_args=()
    [[ -n "$raw_args" ]] && s_args=( "${(@Q)${(@z)raw_args}}" )
    local -A u_opts=()
    if [[ "$raw_args" == *--(prefix|suffix|format)* ]]; then
      () {
        set -- "$@"
        zparseopts -D -E -A u_opts -K -prefix:=u_opts -suffix:=u_opts -format:=u_opts 2>/dev/null
        s_args=( "$@" )
      } "${s_args[@]}"
    fi

    (( ! $+functions[zline_segment_${name}] && $+functions[_zline_load_segment] )) && _zline_load_segment "$name"
    if (( $+functions[zline_segment_${name}] )); then
      "zline_segment_${name}" "${s_args[@]}"
    fi
    if (( _zline_icons == 0 )) && (( ${s_args[(Ie)--icon]} == 0 )); then
      _zline_ret_icon=""
    fi

    if [[ -z "$_zline_ret_content" && -z "$_zline_ret_icon" ]]; then
      continue
    fi

    if [[ -n "$_zline_ret_content" && -n "${u_opts[--prefix]}${u_opts[--suffix]}${u_opts[--format]}" ]]; then
      [[ -n "${u_opts[--prefix]}" ]] && _zline_ret_content="${u_opts[--prefix]}${_zline_ret_content}"
      [[ -n "${u_opts[--suffix]}" ]] && _zline_ret_content="${_zline_ret_content}${u_opts[--suffix]}"
      local u_fmt="${u_opts[--format]}"
      if [[ -n "$u_fmt" && $+functions[$u_fmt] -eq 1 ]]; then
        "$u_fmt" "$_zline_ret_content"
        _zline_ret_content="$REPLY"
      fi
    fi

    r_icons+=("$_zline_ret_icon")
    r_contents+=("$_zline_ret_content")
    r_fgs+=("$_zline_ret_fg")
    r_bgs+=("${_zline_ret_bg:-0}")

    if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
      _zline_render_right_segment_powerline "$_zline_ret_icon" "$_zline_ret_content" "$_zline_ret_fg" "${_zline_ret_bg:-0}" "$last_bg"
      out+="$REPLY"
      last_bg="${_zline_ret_bg:-0}"
    else
      _zline_render_left_segment_lean "$_zline_ret_icon" "$_zline_ret_content" "$_zline_ret_fg"
      [[ -n "$out" ]] && out+=" "
      out+="$REPLY"
    fi
  done

  local -i active_cnt=${#r_contents}
  if (( active_cnt == 0 )); then
    _zline_right_len=0
    REPLY=""
    return 0
  fi

  if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
    [[ -n "$out" ]] && out+="%k"
  fi

  if (( max_w <= 0 )); then
    _zline_right_len=0
    REPLY="$out"
    return 0
  fi

  _zline_visual_len "$out"
  _zline_right_len=$REPLY
  if (( _zline_right_len <= max_w )); then
    REPLY="$out"
    return 0
  fi

  # Overflow: progressively drop from the left
  local -i start=2
  local right_str=""
  while (( start <= active_cnt )); do
    out=""
    last_bg="none"
    local -i k
    for (( k = start; k <= active_cnt; k++ )); do
      if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
        _zline_render_right_segment_powerline "${r_icons[k]}" "${r_contents[k]}" "${r_fgs[k]}" "${r_bgs[k]}" "$last_bg"
        out+="$REPLY"
        last_bg="${r_bgs[k]}"
      else
        _zline_render_left_segment_lean "${r_icons[k]}" "${r_contents[k]}" "${r_fgs[k]}"
        [[ -n "$out" ]] && out+=" "
        out+="$REPLY"
      fi
    done
    if [[ "$_zline_style" == "powerline" || "$_zline_style" == "rainbow" ]]; then
      [[ -n "$out" ]] && out+="%k"
    fi
    right_str="$out"
    _zline_visual_len "$right_str"
    _zline_right_len=$REPLY
    if (( _zline_right_len <= max_w )); then
      break
    fi
    (( start += 1 ))
  done

  if (( start > active_cnt )); then
    right_str=""
    _zline_right_len=0
  fi
  REPLY="$right_str"
}

zline_render() {
  emulate -L zsh
  zline_hook run pre_render
  _zline_render_left
  local left_body="$REPLY"

  local -i max_right=0
  local -i left_len=0
  local left_top="${left_body%%$'\n'*}"
  if [[ -n "$COLUMNS" && $COLUMNS -gt 0 ]]; then
    _zline_visual_len "$left_top"
    left_len=$REPLY
    max_right=$(( COLUMNS - left_len - 2 ))
    (( max_right < 0 )) && max_right=0
  fi

  _zline_render_right "$max_right"
  local right_body="$REPLY"
  local -i right_len=$_zline_right_len

  if [[ -n "$right_body" && -n "$COLUMNS" && $COLUMNS -gt 0 ]]; then

    local frame_end=""
    if [[ "$_zline_frame" == "full" ]]; then
      if [[ "$_zline_mode" == "ascii" ]]; then
        frame_end=" -+"
      elif [[ "$_zline_frame_shape" == "sharp" ]]; then
        frame_end=" %F{8}"$'\u2500\u2510'"%f"
      elif [[ "$_zline_frame_shape" == "double" ]]; then
        frame_end=" %F{8}"$'\u2550\u2557'"%f"
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
