Describe 'zline framework compatibility and profiling'
  Include ./zline.zsh

  Describe 'preset inspection'
    It 'lists available presets'
      When call zline preset list
      The output should include "powerline"
      The output should include "lean"
    End
  End
End
