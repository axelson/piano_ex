# PianoEx

Monorepo for a Pandora player (pianobar) visualizer and controller.

## Repository Structure

Single git repo containing multiple Elixir projects:

- `piano_ctl/` — Core library. Controls pianobar (play/stop/next via control FIFO) and parses pianobar events (song changes via BEAMNotify). No UI.
- `piano_phx/` — Phoenix LiveView web frontend. Depends on `piano_ctl` as a path dependency. Run with `mix phx.server` from `piano_phx/`.
- `piano_ui/` — Scenic (native GUI) frontend. Runs on embedded devices.

## Data Flow

```
pianobar → command.sh → BEAMNotify → PianoCtl.PianoInputReader
                                          ↓
                                     PianoCtl.Server → PianoCtl.Visualizer
                                                            ↓
                                                   Phoenix.PubSub broadcast
                                                            ↓
                                                   PianoPhx.DashboardLive
```

## Commands

Run from the relevant project directory (`piano_phx/` or `piano_ctl/`):

- `mix setup` — install deps and build assets
- `mix phx.server` — start dev server (piano_phx)
- `mix test` — run tests
- `mix precommit` — compile (warnings-as-errors), unlock unused deps, format, test (piano_phx)
