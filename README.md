# homebrew-actop

Homebrew tap for [`actop`](https://github.com/binlecode/actop) — the sudoless
Apple-Silicon `*top` (CPU/GPU/ANE/memory/power/thermal).

## Install

```sh
brew tap binlecode/actop
brew install actop
```

`brew tap binlecode/actop` resolves to this repo (`binlecode/homebrew-actop`).

## Maintenance

`Formula/actop.rb` is kept in sync automatically: on every `v*` tag pushed to
`binlecode/actop`, the `release-formula` workflow there updates the `url`,
`sha256`, and pinned Python resources in this repo. Do not edit by hand during a
release.
