Describe 'zline advanced directory and precision'
  Include ./zline.zsh

  Describe 'duration precision'
    It 'formats duration with 2 decimal places'
      When call _zline_format_duration 5.678 2
      The variable REPLY should eq "5.67s"
    End
  End
End
