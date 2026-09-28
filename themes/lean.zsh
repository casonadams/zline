_zline_style="lean"

zline_left=(
  'dir --shorten 1 --anchor git --color 4'
  'git --clean 2 --dirty 3'
  newline
  prompt_char
)

zline_right=(
  'status --hide-zero'
  'exec_time --min 2'
)
