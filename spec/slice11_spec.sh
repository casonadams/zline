Describe 'zline title manager & packaging'
  Include ./zline.zsh

  Describe 'title manager'
    It 'enables title by default'
      The variable _zline_title_enabled should eq 1
    End

    It 'allows disabling title manager'
      _zline_title_enabled=0
      The variable _zline_title_enabled should eq 0
      _zline_title_enabled=1
    End
  End
End
