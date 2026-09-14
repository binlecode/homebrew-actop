# homebrew-actop

Homebrew tap for two of binlecode's terminal tools:

- [`actop`](https://github.com/binlecode/actop) — the sudoless Apple-Silicon
  `*top` (CPU/GPU/ANE/memory/power/thermal).
- [`ting`](https://github.com/binlecode/ting) — the agent-first media engine
  with a terminal face (search, play, control mpv).

## Install

```sh
brew tap binlecode/actop
brew install actop
brew install ting
```

`ting` was called `uting` up to v0.8.2. `formula_renames.json` carries the
mapping, so an existing `brew install binlecode/actop/uting` migrates on the
next `brew update`.

The pre-rename command names (`uting`, `ut-play`, `ut-playlist`, `ut-history`)
shipped inside the keg for v0.9.0 only; upstream deleted them in v0.10.0, so a
keg from here now has one name per command. Files are unaffected — a config at
`~/.config/uting/config` and a store at `~/.local/state/uting` are still read.

`brew tap binlecode/actop` resolves to this repo (`binlecode/homebrew-actop`).

## Maintenance

`Formula/actop.rb` is kept in sync automatically: on every `v*` tag pushed to
`binlecode/actop`, the `release-formula` workflow there updates the `url`,
`sha256`, and pinned Python resources in this repo. Do not edit by hand during a
release.
