Describe 'zline stash and curated presets'
  Include ./zline.zsh

  Describe 'stash details'
    It 'formats stash badge'
      _zline_git_cache_ahead=0
      _zline_git_cache_behind=0
      _zline_git_cache_conflicts=0
      _zline_git_cache_staged=0
      _zline_git_cache_unstaged=0
      _zline_git_cache_untracked=0
      When call _zline_git_format_details "" "" 1 "*"
      The variable REPLY should eq "*1"
    End
  End
End
