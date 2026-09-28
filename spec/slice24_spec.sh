Describe 'zline swift, dart, julia, and ocaml segments'
  Include ./zline.zsh

  Describe 'swift runtime detection'
    It 'detects Package.swift'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      touch Package.swift
      When call zline_segment_swift
      The variable _zline_ret_content should eq "swift"
      The variable _zline_ret_fg should eq "9"
      rm -rf "$t_dir"
    End
  End

  Describe 'dart runtime detection'
    It 'detects pubspec.yaml'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      touch pubspec.yaml
      When call zline_segment_dart
      The variable _zline_ret_content should eq "dart"
      The variable _zline_ret_fg should eq "12"
      rm -rf "$t_dir"
    End
  End

  Describe 'julia runtime detection'
    It 'detects Project.toml'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      touch Project.toml
      When call zline_segment_julia
      The variable _zline_ret_content should eq "jl"
      The variable _zline_ret_fg should eq "13"
      rm -rf "$t_dir"
    End
  End

  Describe 'ocaml runtime detection'
    It 'detects dune-project'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      touch dune-project
      When call zline_segment_ocaml
      The variable _zline_ret_content should eq "ml"
      The variable _zline_ret_fg should eq "11"
      rm -rf "$t_dir"
    End
  End
End
