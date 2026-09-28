class Zline < Formula
  desc "Fast, modern, and flexible pure-Zsh prompt engine"
  homepage "https://github.com/casonadams/zline"
  url "https://github.com/casonadams/zline/archive/refs/tags/v0.1.0.tar.gz"
  license "MIT"

  depends_on "zsh"

  def install
    pkgshare.install "zline.zsh", "zline.plugin.zsh"
    pkgshare.install "lib", "segments", "themes"
    man1.install "man/man1/zline.1"
  end

  def caveats
    <<~EOS
      To activate zline, add the following to your ~/.zshrc:
        source #{opt_pkgshare}/zline.zsh
        zline preset powerline --transient
        zline init
    EOS
  end

  test do
    system "zsh", "-c", "source #{pkgshare}/zline.zsh && zline version"
  end
end
