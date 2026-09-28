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
    When call _zline_dir_format_path "$HOME/src/github.com/casonadams/zline" 1 1 "none" test_aliases
    The variable REPLY should eq "~/s/gith/c/zline"
  End

  Describe 'git repository anchor'
    format_test_anchor() {
      typeset test_repo="/tmp/zline_anchor_spec"
      mkdir -p "${test_repo}/.git" "${test_repo}/sub1/sub2"
      typeset -a test_aliases=()
      _zline_dir_format_path "${test_repo}/sub1/sub2" 1 1 "git" test_aliases
      typeset res="$REPLY"
      rm -rf "$test_repo"
      REPLY="$res"
    }

    It 'anchors git repository root'
      When call format_test_anchor
      The variable REPLY should eq "/t/zline_anchor_spec/s/sub2"
    End
  End
End
