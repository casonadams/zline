Describe 'zline OSC protocols'
  Include ./zline.zsh

  It 'generates OSC 133;A and OSC 7 prompt prefix'
    _zline_osc=1
    When call _zline_osc_prompt_prefix
    The variable REPLY should start with "%{"
    The variable REPLY should end with "%}"
    The variable REPLY should include "133;A"
    The variable REPLY should include "7;file://"
  End

  It 'generates OSC 133;B prompt suffix'
    _zline_osc=1
    When call _zline_osc_prompt_suffix
    The variable REPLY should include "133;B"
  End

  It 'returns empty string when OSC is disabled'
    _zline_osc=0
    When call _zline_osc_prompt_prefix
    The variable REPLY should eq ""
  End
End
