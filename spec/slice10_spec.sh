Describe 'zline developer ecosystem segments'
  Include ./zline.zsh

  Describe 'terraform segment'
    It 'detects TF_WORKSPACE'
      export TF_WORKSPACE="staging"
      When call zline_segment_terraform
      The variable _zline_ret_content should eq "staging"
      The variable _zline_ret_fg should eq "5"
    End
  End

  Describe 'docker segment'
    It 'detects DOCKER_CONTEXT'
      export DOCKER_CONTEXT="desktop-linux"
      When call zline_segment_docker
      The variable _zline_ret_content should eq "desktop-linux"
      The variable _zline_ret_fg should eq "4"
    End
  End
End
