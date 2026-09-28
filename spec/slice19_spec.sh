Describe 'zline developer environments and universal tool-versions'
  Include ./zline.zsh

  Describe 'nix_shell detection'
    It 'detects pure nix-shell'
      IN_NIX_SHELL="pure"
      When call zline_segment_nix_shell
      The variable _zline_ret_content should eq "pure"
      The variable _zline_ret_fg should eq "14"
    End
  End

  Describe 'direnv detection'
    It 'detects active direnv directory'
      DIRENV_DIR="-/tmp/my-project"
      When call zline_segment_direnv
      The variable _zline_ret_content should eq "my-project"
      The variable _zline_ret_fg should eq "11"
    End
  End

  Describe 'universal tool-versions reader'
    It 'parses target tool version'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      printf "nodejs 20.10.0\nrust 1.75.0\n" > .tool-versions
      _test_tool() {
        _zline_read_tool_version "rust"
      }
      When call _test_tool
      The variable REPLY should eq "1.75.0"
      rm -rf "$t_dir"
    End
  End
End
