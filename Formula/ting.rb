class Ting < Formula
  desc "Agent-first media engine with a terminal face: search, play, control mpv"
  homepage "https://github.com/binlecode/ting"
  url "https://github.com/binlecode/ting/archive/refs/tags/v0.18.0.tar.gz"
  sha256 "7d2b9a47c8434e7895340f3101b852b3c739bc9363b982439282b1f364debe2c"
  license "MIT"

  depends_on "jq"
  depends_on "mpv"
  depends_on "yt-dlp"

  # Seven executables that share no library: four public commands and three engine files.
  # They locate VERSION and the shipped `config` one level above their own RESOLVED path,
  # walking any symlink chain first, so the tree has to be installed whole and the bins have
  # to be symlinks into it — copying the scripts into bin/ would put them one directory away
  # from both files and break --version and every default in the suite.
  #
  # Only the four public commands go on PATH. The engines (t-engine-yt, t-engine-bili,
  # t-engine-ne) are t-play's internal protocol, not a contract: t-play finds them beside its
  # own resolved path, in libexec/shell, and every engine verb is reached as
  # `t-play --search/--info/--items/--transcript/--auth`.
  def install
    libexec.install "shell", "config", "VERSION"
    %w[ting t-play t-playlist t-history].each { |cmd| bin.install_symlink libexec/"shell/#{cmd}" }
    doc.install "README.md", "docs"
  end

  def caveats
    <<~EOS
      Playback needs a netcat that speaks unix sockets for the runtime control verbs
      (--pause, --seek, --set-volume, --set-loop). macOS ships one; on Linux install
      netcat-openbsd or nmap's ncat.

      As of 0.18.0 the six yt-/bili-/ne-search/-resolve commands are gone: every engine verb
      is `t-play --search/--info/--items/--transcript/--auth [--engine E]`. Every config key
      is TING_-prefixed (TING_<KEY>, engine keys TING_<ENGINE>_<KEY>); a config file is read
      only for TING_ keys, so rename any old keys in ~/.config/ting/config. The pre-rename locations
      (~/.config/uting, ~/.local/state/uting) are no longer read.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ting --version")
    assert_match version.to_s, shell_output("#{bin}/t-play --version")
    # The lifecycle half answers without a network: no player is a real, empty answer.
    assert_match "\"players\":[]", shell_output("#{bin}/t-play --status -j")
    # Dropping the legacy lookup arms could only have broken one thing: the TUI finding its
    # own player. WHICH gate answers first depends on what the test machine has on PATH — a
    # missing unix-socket netcat speaks before the tty gate does — so the claim is the
    # negative one, which holds under every gate: it never gets as far as not finding t-play.
    refute_match "cannot locate", shell_output("#{bin}/ting q </dev/null 2>&1 || true")
    # t-play finds its engines in libexec, not on PATH: all three answer, each with flags.
    engines = shell_output("#{bin}/t-play --engines -j")
    %w[yt bili ne].each { |e| assert_match "\"name\":\"#{e}\"", engines }
    refute_match "\"flags\":[]", engines
  end
end
