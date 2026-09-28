_zline_style="powerline"

zline_left=(
  'dir --shorten 1 --anchor git --bg 3 --fg 0'
  'git --clean 2 --dirty 1 --fg 0'
  newline
  'prompt_char --symbol ❯ --color 11'
)

zline_right=(
  'status --hide-zero --bg 1 --fg 15'
  'exec_time --min 2 --bg 8 --fg 15'
)
