Describe 'zline directory segment'
  Include ./zline.zsh

  It 'shortens intermediate path components'
    typeset -a test_aliases=()
    When call _zline_dir_format_path "/var/log/nginx" 1 1 "none" test_aliases
    The variable REPLY should eq "/v/l/nginx"
  End

  It 'preserves full path when shortening is 0'
    typeset -a test_aliases=()
    When call _zline_dir_format_path "/var/log/nginx" 0 1 "none" test_aliases
    The variable REPLY should eq "/var/log/nginx"
  End

  It 'replaces $HOME with ~'
    typeset -a test_aliases=()
    When call _zline_dir_format_path "$HOME" 1 1 "none" test_aliases
    The variable REPLY should eq "~"
  End

  It 'substitutes directory aliases'
    typeset -a test_aliases=("--alias" "github.com=gith")
    When call _zline_dir_format_path "/Users/cadams/src/github.com/casonadams/zline" 1 1 "none" test_aliases
    The variable REPLY should eq "~/s/gith/c/zline"
  End

  It 'anchors git repository root'
    typeset -a test_aliases=("--alias" "github.com=gith")
    When call _zline_dir_format_path "$PWD" 1 1 "git" test_aliases
    The variable REPLY should eq "~/s/gith/c/zline"
  End
End
