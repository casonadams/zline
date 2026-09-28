Describe 'zline hostile option resilience'
  Include ./zline.zsh

  It 'initializes under ksh_arrays'
    setopt ksh_arrays
    When call zline preset powerline --no-osc
    The status should be success
  End
End
