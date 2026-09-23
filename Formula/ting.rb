class Ting < Formula
  desc "Agent-first media engine with a terminal face: search, play, control mpv"
  homepage "https://github.com/binlecode/ting"
  url "https://github.com/binlecode/ting/archive/refs/tags/v0.13.0.tar.gz"
  sha256 "5799cafaa2ba29d6ced2248088ee48075ad5075a0b4e834d9ef174f2eab5cf9f"
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
  # Ten, and only ten. v0.9.0 also linked the pre-rename names (uting, ut-play, ut-playlist,
  # ut-history); upstream deleted those in v0.10.0, so there is nothing left to link and a
  # keg from here has one name per command. An installed 0.9.0 keg loses them on upgrade,
  # which is the breaking half of that release and is upstream's call, not this file's.
  def install
    libexec.install "shell", "config", "VERSION"
    %w[
      ting t-play t-playlist t-history
      yt-search yt-resolve bili-search bili-resolve ne-search ne-resolve
    ].each { |cmd| bin.install_symlink libexec/"shell/#{cmd}" }
    doc.install "README.md", "docs"
  end

  def caveats
    <<~EOS
      Playback needs a netcat that speaks unix sockets for the runtime control verbs
      (--pause, --seek, --set-volume, --set-loop). macOS ships one; on Linux install
      netcat-openbsd or nmap's ncat.

      The pre-rename command names (uting, ut-play, ut-playlist, ut-history) are gone as
      of 0.10.0. Your own files are not: a config at ~/.config/uting/config and a store
      at ~/.local/state/uting are still read where they are.
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
  end
end
