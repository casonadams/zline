Describe 'zline git segment'
  Include ./zline.zsh

  It 'reads current branch synchronously'
    When call _zline_git_read_head "$PWD"
    The variable REPLY should eq "main"
  End

  It 'formats git details badges in nerdfont mode'
    _zline_git_cache_conflicts=1
    _zline_git_cache_staged=2
    _zline_git_cache_unstaged=3
    _zline_git_cache_untracked=4
    _zline_git_cache_ahead=5
    _zline_git_cache_behind=1
    _zline_mode="nerdfont"
    When call _zline_git_format_details
    The variable REPLY should eq "x1 +2 !3 ?4 "$'\u21E1'"5 "$'\u21E3'"1"
  End

  It 'formats git details badges in ascii mode'
    _zline_git_cache_conflicts=1
    _zline_git_cache_staged=2
    _zline_git_cache_unstaged=3
    _zline_git_cache_untracked=4
    _zline_git_cache_ahead=5
    _zline_git_cache_behind=1
    _zline_mode="ascii"
    When call _zline_git_format_details
    The variable REPLY should eq "x1 +2 !3 ?4 ^5 v1"
  End
End
