Describe 'zline base16 color subsystem'
  Include ./lib/color.zsh

  It 'maps semantic color names to ANSI 0-15 codes'
    When call _zline_color_code green
    The variable REPLY should eq 2
  End

  It 'maps bright-cyan to code 14'
    When call _zline_color_code bright-cyan
    The variable REPLY should eq 14
  End

  It 'maps none and transparent to reset'
    When call _zline_color_code none
    The variable REPLY should eq 'reset'
  End

  It 'generates %F foreground escape'
    When call _zline_fg green
    The variable REPLY should eq '%F{2}'
  End

  It 'generates %K background escape'
    When call _zline_bg blue
    The variable REPLY should eq '%K{4}'
  End

  It 'wraps raw escape sequence in %{...%}'
    When call _zline_wrap_raw $'\e[1m'
    The variable REPLY should eq "%{"$'\e[1m'"%}"
  End
End
