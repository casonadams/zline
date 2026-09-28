Describe 'zline rprompt line alignment'
  Include ./zline.zsh

  Describe 'line 1 alignment'
    It 'clears native RPROMPT when embedded on line 1'
      _zline_rprompt_line=1
      _zline_osc=0
      zline preset powerline --no-osc
      zline_right=(time)
      zline init
      COLUMNS=80
      zline_render
      The variable RPROMPT should eq ""
    End
  End
End
