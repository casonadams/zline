Describe 'zline crystal, haskell, scala, and kotlin segments'
  Include ./zline.zsh

  Describe 'crystal runtime detection'
    It 'detects crystal shard'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      touch shard.yml
      When call zline_segment_crystal
      The variable _zline_ret_content should eq "cr"
      The variable _zline_ret_fg should eq "15"
      rm -rf "$t_dir"
    End
  End

  Describe 'haskell runtime detection'
    It 'detects stack project'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      touch stack.yaml
      When call zline_segment_haskell
      The variable _zline_ret_content should eq "hs"
      The variable _zline_ret_fg should eq "5"
      rm -rf "$t_dir"
    End
  End

  Describe 'scala runtime detection'
    It 'detects build.sbt'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      touch build.sbt
      When call zline_segment_scala
      The variable _zline_ret_content should eq "scala"
      The variable _zline_ret_fg should eq "9"
      rm -rf "$t_dir"
    End
  End

  Describe 'kotlin runtime detection'
    It 'detects build.gradle.kts'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      touch build.gradle.kts
      When call zline_segment_kotlin
      The variable _zline_ret_content should eq "kt"
      The variable _zline_ret_fg should eq "13"
      rm -rf "$t_dir"
    End
  End
End
