Describe 'zline cmake segment'
  Include ./zline.zsh

  Describe 'cmake project detection'
    It 'detects project name from CMakeLists.txt'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      printf "project(TestEngine LANGUAGES CXX)\n" > CMakeLists.txt
      When call zline_segment_cmake
      The variable _zline_ret_content should eq "TestEngine"
      The variable _zline_ret_fg should eq "4"
      rm -rf "$t_dir"
    End
  End
End
