_zline_style="lean"

zline_left=(
  'dir --color 4'
  'git --clean 8 --dirty 3'
  newline
  'prompt_char --symbol ❯ --color 15'
)

zline_right=(
  'exec_time --min 2 --color 8'
)
