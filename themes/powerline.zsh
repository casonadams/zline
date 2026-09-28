_zline_style="powerline"

zline_left=(
  'dir --shorten 1 --anchor git --bg 4 --fg 15'
  'git --clean 2 --dirty 3 --fg 0'
  newline
  prompt_char
)

zline_right=(
  'status --hide-zero'
  'exec_time --min 2'
)
