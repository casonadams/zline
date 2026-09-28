Describe 'zline comparison & transient directory'
  Include ./zline.zsh

  Describe 'transient directory'
    It 'enables directory retention'
      _zline_transient=1
      _zline_transient_show_dir=1
      _zline_transient_symbol="❯"
      _zline_transient_color="10"
      _zline_dir_cache_res="~/test"

      When call _zline_transient_line_finish
      The variable PROMPT should include "~/test"
      The variable PROMPT should include "❯"
    End
  End
End
