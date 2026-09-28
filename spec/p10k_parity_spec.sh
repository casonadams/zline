Describe 'zline p10k feature parity'
  Include ./zline.zsh

  Describe 'text segment'
    It 'renders text'
      When call zline_segment_text "MY_BADGE"
      The variable _zline_ret_content should eq "MY_BADGE"
      The variable _zline_ret_fg should eq "7"
    End
  End

  Describe 'git custom icons'
    It 'formats details with custom icons'
      _zline_git_cache_valid=1
      _zline_git_cache_staged=2
      _zline_git_cache_unstaged=1
      _zline_git_cache_untracked=0
      _zline_git_cache_conflicts=0
      _zline_git_cache_ahead=0
      _zline_git_cache_behind=0
      When call _zline_git_format_details "^" "v" 0 "*" "●" "✚" "…" "✖"
      The variable REPLY should eq "●2 ✚1"
      unset _zline_git_cache_valid _zline_git_cache_staged _zline_git_cache_unstaged \
        _zline_git_cache_untracked _zline_git_cache_conflicts _zline_git_cache_ahead _zline_git_cache_behind
    End
  End

  Describe 'dir tail truncation'
    It 'truncates path to last 2 components'
      local -a empty_aliases=()
      When call _zline_dir_format_path "/one/two/three/four" 0 1 "none" empty_aliases 2
      The variable REPLY should eq ".../three/four"
    End
  End
End
