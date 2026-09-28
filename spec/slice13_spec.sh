Describe 'zline hyperlinks and user context'
  Include ./zline.zsh

  Describe 'hyperlinks'
    It 'formats OSC 8 escape sequences'
      _zline_osc=1
      _zline_osc_hyperlinks=1
      When call _zline_osc_hyperlink "https://example.com" "test"
      The variable REPLY should include "8;;https://example.com"
      The variable REPLY should include "test"
    End
  End

  Describe 'user_host'
    It 'returns empty when local'
      SSH_CLIENT="" SSH_TTY="" SSH_CONNECTION=""
      When call zline_segment_user_host
      The variable _zline_ret_content should eq ""
    End
  End
End
