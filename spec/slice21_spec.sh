Describe 'zline vi_mode, gcp, azure, and elixir segments'
  Include ./zline.zsh

  Describe 'vi_mode keymap tracking'
    It 'detects normal mode in vicmd'
      _zline_vi_mode="vicmd"
      KEYMAP="vicmd"
      When call zline_segment_vi_mode
      The variable _zline_ret_content should eq "NOR"
      The variable _zline_ret_fg should eq "11"
    End

    It 'hides insert mode when --hide-insert is set'
      _zline_vi_mode="main"
      KEYMAP="main"
      When call zline_segment_vi_mode --hide-insert
      The variable _zline_ret_content should eq ""
    End
  End

  Describe 'gcp project resolution'
    It 'resolves cloudsdk project variable'
      CLOUDSDK_CORE_PROJECT="my-cloud-spec-app"
      When call zline_segment_gcp
      The variable _zline_ret_content should eq "my-cloud-spec-app"
      The variable _zline_ret_fg should eq "12"
      unset CLOUDSDK_CORE_PROJECT
    End
  End

  Describe 'elixir runtime detection'
    It 'detects mix.exs project'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      touch mix.exs
      When call zline_segment_elixir
      The variable _zline_ret_content should eq "ex"
      The variable _zline_ret_fg should eq "5"
      rm -rf "$t_dir"
    End
  End
End
