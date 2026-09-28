Describe 'zline segment library'
  Include ./zline.zsh

  Describe 'status segment'
    It 'hides zero exit status by default'
      _zline_last_exit_code=0
      When call zline_segment_status
      The variable _zline_ret_content should eq ""
    End

    It 'shows failure exit status'
      _zline_last_exit_code=1
      When call zline_segment_status
      The variable _zline_ret_content should eq "1"
      The variable _zline_ret_fg should eq "9"
    End
  End

  Describe 'exec_time segment'
    It 'hides durations below minimum threshold'
      _zline_last_duration=0.5
      When call zline_segment_exec_time --min 2
      The variable _zline_ret_content should eq ""
    End

    It 'formats duration when above threshold'
      _zline_last_duration=3.5
      When call zline_segment_exec_time --min 2
      The variable _zline_ret_content should eq "3.5s"
    End
  End

  Describe 'prompt_char segment'
    It 'renders default prompt symbol'
      _zline_last_exit_code=0
      _zline_vi_mode="main"
      When call zline_segment_prompt_char
      The variable _zline_ret_content should eq "❯"
      The variable _zline_ret_fg should eq "15"
    End

    It 'renders error color when exit status non-zero'
      _zline_last_exit_code=1
      When call zline_segment_prompt_char
      The variable _zline_ret_fg should eq "9"
    End
  End

  Describe 'venv segment'
    It 'detects virtual environment name'
      export VIRTUAL_ENV="/home/user/.virtualenvs/test-app"
      When call zline_segment_venv
      The variable _zline_ret_content should eq "test-app"
      The variable _zline_ret_fg should eq "5"
    End
  End
End
