class Ting < Formula
  desc "Agent-first media engine with a terminal face: search, play, control mpv"
  homepage "https://github.com/binlecode/ting"
  url "https://github.com/binlecode/ting/archive/refs/tags/v0.9.0.tar.gz"
  sha256 "866ef72e93b074daedb032095e0e594f0abc1601189546eb1e02e238408386de"
  license "MIT"

  depends_on "jq"
  depends_on "mpv"
  depends_on "yt-dlp"

  # Ten independent executables that share no library. They locate VERSION and the shipped
  # `config` one level above their own RESOLVED path, walking any symlink chain first, so the
  # tree has to be installed whole and the bins have to be symlinks into it — copying the
  # scripts into bin/ would put them one directory away from both files and break --version
  # and every default in the suite.
  #
  # The four names in the second list are the suite's pre-rename spelling, and they are
  # shipped for the same reason the checkout ships them: someone's script says `ut-play`.
  # Each is a symlink inside `shell/` pointing at its new name, so linking it into bin gives
  # a two-hop chain that still resolves into libexec/shell — which is what the paragraph
  # above needs and what the test below proves rather than assumes.
  def install
    libexec.install "shell", "config", "VERSION"
    %w[
      ting t-play t-playlist t-history
      yt-search yt-resolve bili-search bili-resolve ne-search ne-resolve
      uting ut-play ut-playlist ut-history
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
    assert_match version.to_s, shell_output("#{bin}/ting --version")
    assert_match version.to_s, shell_output("#{bin}/t-play --version")
    # The lifecycle half answers without a network: no player is a real, empty answer.
    assert_match "\"players\":[]", shell_output("#{bin}/t-play --status -j")
    # The pre-rename names, through the two-hop symlink: a chain that lost its footing
    # would answer `unknown` here rather than the version, which is the failure the
    # install comment is about.
    assert_match version.to_s, shell_output("#{bin}/uting --version")
    assert_match version.to_s, shell_output("#{bin}/ut-play --version")
  end
end
