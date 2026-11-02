_zline_style="powerline"
_zline_frame="full"
_zline_connect_char="─"
_zline_connect_color="8"
_zline_sep_soft_color="7"

zline_left=(
  'dir --shorten 1 --anchor git --bg 8 --fg 4'
  'git --clean 2 --dirty 3 --bg 8'
  newline
)

zline_right=(
  'status --hide-zero --bg 8 --fg 9'
  'exec_time --min 3 --bg 8 --fg 7'
  'jobs --bg 8 --fg 6'
  'direnv --bg 8 --fg 3'
  'venv --bg 8 --fg 2'
)
