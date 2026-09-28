Describe 'zline long-running command notifications, bun and deno runtimes'
  Include ./zline.zsh

  Describe 'bun runtime detection'
    It 'detects bun project via bun.lockb'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      touch bun.lockb
      When call zline_segment_bun
      The variable _zline_ret_content should eq "bun"
      The variable _zline_ret_fg should eq "15"
      rm -rf "$t_dir"
    End
  End

  Describe 'deno runtime detection'
    It 'detects deno project via deno.json'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      touch deno.json
      When call zline_segment_deno
      The variable _zline_ret_content should eq "deno"
      The variable _zline_ret_fg should eq "10"
      rm -rf "$t_dir"
    End
  End

  Describe 'notification controls'
    It 'configures notification threshold'
      When call zline notify on 25
      The stdout should include "Desktop notifications enabled"
      The variable _zline_notify_enabled should eq 1
      The variable _zline_notify_threshold should eq 25
    End
  End
End
