Describe 'zline extended segments & compilation'
  Include ./zline.zsh

  Describe 'time segment'
    It 'formats current time'
      When call zline_segment_time --format "%H:%M"
      The variable _zline_ret_content should not eq ""
      The variable _zline_ret_fg should eq "8"
    End
  End

  Describe 'aws segment'
    It 'formats AWS profile and region'
      export AWS_PROFILE="test-profile"
      export AWS_REGION="eu-central-1"
      When call zline_segment_aws
      The variable _zline_ret_content should eq "test-profile (eu-central-1)"
      The variable _zline_ret_fg should eq "3"
    End
  End

  Describe 'frame connectors'
    It 'renders top and bottom frame glyphs'
      _test_frame() {
        _zline_frame="left"
        zline preset powerline --no-osc
        zline init
        _zline_hooks_uninstall
        _zline_frame="none"
      }
      When call _test_frame
      The variable PROMPT should include "╭─"
      The variable PROMPT should include "╰─"
    End
  End
End
