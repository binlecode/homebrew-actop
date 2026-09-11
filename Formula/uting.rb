class Uting < Formula
  desc "Agent-first media engine with a terminal face: search, play, control mpv"
  homepage "https://github.com/binlecode/uting"
  url "https://github.com/binlecode/uting/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "79b310888c523c8dae325e81d434a9005421df07c74e1692014bd3b3e37cbddf"
  license "MIT"

  depends_on "jq"
  depends_on "mpv"
  depends_on "yt-dlp"

  # Ten independent executables that share no library. They locate VERSION and the shipped
  # `config` one level above their own RESOLVED path, walking any symlink chain first, so the
  # tree has to be installed whole and the bins have to be symlinks into it — copying the
  # scripts into bin/ would put them one directory away from both files and break --version
  # and every default in the suite.
  def install
    libexec.install "shell", "config", "VERSION"
    %w[
      uting ut-play ut-playlist ut-history
      yt-search yt-resolve bili-search bili-resolve ne-search ne-resolve
    ].each { |cmd| bin.install_symlink libexec/"shell/#{cmd}" }
    doc.install "README.md", "docs"
  end

  def caveats
    <<~EOS
      Playback needs a netcat that speaks unix sockets for the runtime control verbs
      (--pause, --seek, --set-volume, --set-loop). macOS ships one; on Linux install
      netcat-openbsd or nmap's ncat.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/uting --version")
    assert_match version.to_s, shell_output("#{bin}/ut-play --version")
    # The lifecycle half answers without a network: no player is a real, empty answer.
    assert_match "\"players\":[]", shell_output("#{bin}/ut-play --status -j")
  end
end
