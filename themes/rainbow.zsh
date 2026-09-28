_zline_style="rainbow"

zline_left=(
  'dir --shorten 1 --anchor git --bg 4 --fg 15'
  'git --clean 2 --dirty 3 --fg 0'
  newline
  prompt_char
)

zline_right=(
  'venv --bg 5 --fg 15'
  'status --hide-zero --bg 1 --fg 15'
  'exec_time --min 2 --bg 3 --fg 0'
)
