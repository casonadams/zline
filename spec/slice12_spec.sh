Describe 'zline completion and git provider'
  Include ./zline.zsh

  Describe 'git provider'
    It 'defaults to cli provider'
      The variable _zline_git_provider should eq "cli"
    End
  End
End
