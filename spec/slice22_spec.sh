Describe 'zline os, container, and shlvl segments'
  Include ./zline.zsh

  Describe 'os segment'
    It 'supports custom symbol override'
      When call zline_segment_os --symbol "os:" --color 15
      The variable _zline_ret_icon should eq "os:"
      The variable _zline_ret_fg should eq "15"
    End
  End

  Describe 'container segment'
    It 'detects WSL environment variable'
      WSL_DISTRO_NAME="Ubuntu-Test"
      When call zline_segment_container
      The variable _zline_ret_content should eq "Ubuntu-Test"
      The variable _zline_ret_fg should eq "14"
      unset WSL_DISTRO_NAME
    End
  End

  Describe 'shlvl segment'
    It 'displays nesting level when above threshold'
      SHLVL=3
      When call zline_segment_shlvl
      The variable _zline_ret_content should eq "3"
      The variable _zline_ret_fg should eq "9"
      unset SHLVL
    End
  End
End
