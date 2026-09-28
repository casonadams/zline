_zline_style="lean"

zline_left=(
  'dir --shorten 1 --anchor git --color 12'
  'git --clean 14 --dirty 11'
  newline
  'prompt_char --symbol ❯ --color 15'
)

zline_right=(
  'status --hide-zero --color 9'
  'exec_time --min 2 --color 11'
  'time --format %H:%M --color 8'
)
