Describe 'zline ZLE cursor safety'
  Include ./zline.zsh

  It 'measures visual column width correctly'
    s="%F{10}hello%f"
    When call _zline_visual_len "$s"
    The variable REPLY should eq 5
  End
End
