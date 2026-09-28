Describe 'zline transient prompt & vi-mode'
  Include ./zline.zsh

  It 'collapses prompt on line finish when enabled'
    _zline_transient=1
    _zline_transient_symbol="❯"
    _zline_transient_color="10"
    PROMPT="FULL_PROMPT"
    RPROMPT="FULL_RPROMPT"

    When call _zline_transient_line_finish
    The variable PROMPT should eq "%F{10}❯%f "
    The variable RPROMPT should eq ""
  End

  It 'leaves prompt untouched when transient is disabled'
    _zline_transient=0
    PROMPT="FULL_PROMPT"
    When call _zline_transient_line_finish
    The variable PROMPT should eq "FULL_PROMPT"
  End

  It 'updates vi-mode to vicmd on keymap select'
    KEYMAP="vicmd"
    When call _zline_vi_keymap_select
    The variable _zline_vi_mode should eq "vicmd"
  End
End
