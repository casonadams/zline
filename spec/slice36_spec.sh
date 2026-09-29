Describe 'Slice 36: ZLE Interactive Protection, Progressive Overflow & Lazy Engine'
  Include ./zline.zsh
  _zline_osc=0

  Describe '_zline_find_up helper'
    It 'finds files in parent directories'
      When call _zline_find_up "README.md"
      The status should be success
      The variable REPLY should end with "README.md"
    End

    It 'returns failure for nonexistent files'
      When call _zline_find_up "totally_nonexistent_file_xyz.txt"
      The status should be failure
      The variable REPLY should eq ""
    End
  End

  Describe 'unquoted token compilation'
    It 'compiles unquoted tokens with flags and empty icons'
      zline_left=(dir --shorten 1 git --clean 2 --icon "" prompt_char)
      zline_right=()
      zline_compile
      res="${(j:,:)_zline_compiled_left_names}"
      When call echo "$res"
      The output should eq "dir,git,prompt_char"
    End
  End

  Describe 'progressive right prompt overflow'
    It 'progressively drops leftmost segments on narrow widths'
      zline_segment_m1() { _zline_ret_content="first"; _zline_ret_fg="1"; }
      zline_segment_m2() { _zline_ret_content="second"; _zline_ret_fg="2"; }
      zline_segment_m3() { _zline_ret_content="third"; _zline_ret_fg="3"; }
      zline_right=(m1 m2 m3)
      zline style lean --no-icons
      zline_compile

      When call _zline_render_right 12
      The variable REPLY should eq "%F{2}second%f %F{3}third%f"
    End
  End

  Describe 'global --no-icons flag'
    It 'suppresses segment icons when active'
      zline_segment_m_ic() { _zline_ret_content="text"; _zline_ret_icon="IC:"; _zline_ret_fg="7"; }
      zline_left=(m_ic)
      zline_right=()
      zline style lean --no-icons
      zline_compile
      When call zline_render
      The variable PROMPT should eq "%F{7}text%f "
    End
  End
End
