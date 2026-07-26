# Piano Phx

Web interface for controlling pianobar, built with Phoenix 1.8 and LiveView.

## Commands

- `mix setup` — install deps and build assets
- `mix phx.server` — start dev server at localhost:4000
- `mix test` — run tests
- `mix precommit` — compile (warnings-as-errors), unlock unused deps, format, test

## Architecture

Single-namespace project: all modules live under `PianoPhx` (no separate Web namespace). The `PianoPhx` module in `lib/piano_phx.ex` is the macro dispatcher (`use PianoPhx, :controller`, etc.).

## Stack

Elixir, Phoenix 1.8, LiveView, Tailwind CSS, daisyUI, Bandit
