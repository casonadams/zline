Describe 'zline connection lines & language runtimes'
  Include ./zline.zsh

  Describe 'ruby segment'
    It 'returns empty when no ruby project'
      When call zline_segment_ruby
      The variable _zline_ret_content should eq ""
    End
  End

  Describe 'java segment'
    It 'returns empty when no java project'
      When call zline_segment_java
      The variable _zline_ret_content should eq ""
    End
  End
End
