# LiveView Dashboard for Pianobar

## Goal

Replace the Scenic-based `piano_ui` with a Phoenix LiveView dashboard in `piano_phx` that displays the currently-playing song (title, artist, album, cover art) and provides play/stop/next controls.

## Approach

Add `piano_ctl` as a path dependency to `piano_phx`. Modify `PianoCtl.Visualizer` to broadcast song events over a configurable Phoenix PubSub instead of calling `PianoUi` directly. Build a single LiveView at `/` that subscribes to those events and renders the dashboard.

`piano_ctl` continues to start itself via its own OTP Application — `piano_phx` only provides config values.

## Changes

### piano_ctl

**`lib/piano_ctl/visualizer.ex`** — Replace the hard-coded `PianoUi.Scene.Dashboard.update_song/1` call with a `Phoenix.PubSub.broadcast/3` using a PubSub name and topic read from application env:

```elixir
def show(%Song{} = song) do
  pubsub = Application.fetch_env!(:piano_ctl, :pubsub)
  topic = Application.fetch_env!(:piano_ctl, :song_topic)
  Phoenix.PubSub.broadcast(pubsub, topic, {:song_started, song})
end
```

**`config/config.exs`** — Add default values for the new config keys:

```elixir
config :piano_ctl, pubsub: nil
config :piano_ctl, song_topic: "piano:now_playing"
```

### piano_phx

**`mix.exs`** — Add `piano_ctl` as a path dependency:

```elixir
{:piano_ctl, path: "../piano_ctl"}
```

**`config/config.exs`** — Add `piano_ctl` config:

```elixir
config :piano_ctl,
  pubsub: PianoPhx.PubSub,
  song_topic: "piano:now_playing",
  libcluster_hosts: []
```

**`lib/piano_phx/router.ex`** — Replace the `PageController` route with a LiveView:

```elixir
scope "/", PianoPhx do
  pipe_through :browser
  live "/", DashboardLive
end
```

**`lib/piano_phx/dashboard_live.ex`** (new) — Single LiveView that:

- On mount, subscribes to `"piano:now_playing"` and calls `PianoCtl.get_current_song/0` to load any current song
- Renders song info (title, artist, album) and an `<img>` tag with the cover art CDN URL
- Renders play, stop, and next buttons
- Handles `{:song_started, song}` messages to update the displayed song
- Handles button click events by calling `PianoCtl.Server.cmd/1` with `:play`, `:stop`, or `:next`

**`lib/piano_phx/page_controller.ex`** — Delete (replaced by LiveView).

**`lib/piano_phx/controllers/page_html.ex`** and **`lib/piano_phx/controllers/page_html/home.html.heex`** — Delete (no longer needed).

## Implementation Notes

- Added `{:phoenix_pubsub, "~> 2.0"}` to `piano_ctl/mix.exs` — it was needed as a direct dependency since the Visualizer now calls `Phoenix.PubSub.broadcast/3`. Previously it was available transitively through `piano_ui`.
- Replaced the old `PageControllerTest` with a `DashboardLiveTest` that verifies the "no song playing" state renders correctly.
- Used `Application.compile_env!/2` for the topic in the LiveView module attribute to avoid runtime config lookups on every mount.
