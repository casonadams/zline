Describe 'zline helm and pulumi segments'
  Include ./zline.zsh

  Describe 'helm chart detection'
    It 'detects Chart.yaml'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      printf "name: test-chart\nversion: 0.1.0\n" > Chart.yaml
      When call zline_segment_helm
      The variable _zline_ret_content should eq "test-chart:0.1.0"
      The variable _zline_ret_fg should eq "14"
      rm -rf "$t_dir"
    End
  End

  Describe 'pulumi project detection'
    It 'detects Pulumi.yaml and stack'
      t_dir=$(mktemp -d)
      cd "$t_dir"
      printf "name: my-infra\n" > Pulumi.yaml
      PULUMI_STACK="dev"
      When call zline_segment_pulumi
      The variable _zline_ret_content should eq "my-infra:dev"
      The variable _zline_ret_fg should eq "13"
      unset PULUMI_STACK
      rm -rf "$t_dir"
    End
  End
End
