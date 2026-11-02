_zline_style="lean"

zline_left=(
  user_host
  'dir --color 4'
  'git --clean 8 --dirty 3'
  'exec_time --min 5 --color 3'
  newline
  venv
  'prompt_char --symbol ❯ --color 15'
)

zline_right=()
