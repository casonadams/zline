_zline_style="powerline"

zline_left=(
  'dir --shorten 1 --anchor git --bg 12 --fg 0'
  'git --clean 10 --dirty 11 --fg 0'
  newline
  'prompt_char --symbol ❯ --color 14'
)

zline_right=(
  'k8s --bg 6 --fg 0'
  'status --hide-zero --bg 9 --fg 15'
  'exec_time --min 2 --bg 3 --fg 0'
)
