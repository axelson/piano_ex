import Config

import JaxUtils.ConfigHelpers

if Config.config_env() == :dev do
  DotenvParser.load_file(".env")
end

config :piano_ui, :calendar_urls, get_env("PIANO_UI_CALENDAR_URLS", :no_default, :csv)
config :piano_ui, :calendar_fetcher_impl, PianoUi.CalendarFetcher.Impl

ctl_node =
  case System.get_env("PIANO_UI_CTL_NODE") do
    nil -> nil
    node -> String.to_atom(node)
  end

config :piano_ui, :ctl_node, ctl_node
config :piano_ui, libcluster_hosts: [ctl_node]
config :piano_ui, :album_cache_dir, System.tmp_dir!() <> "/piano_ex_album_art/"

config :piano_ui,
       :libcluster_strategy,
       (case System.get_env("PIANO_UI_LIBCLUSTER_STRATEGY", "epmd") do
          "epmd" -> Cluster.Strategy.Epmd
          "local_epmd" -> Cluster.Strategy.LocalEpmd
        end)

config :piano_ui, PianoUi.Repo,
  database: "priv/database.db",
  journal_mode: :wal,
  cache_size: -64000,
  temp_store: :memory,
  pool_size: 1

config :piano_ui, :viewport,
  name: :main_viewport,
  size: {800, 480},
  default_scene: {PianoUi.Scene.Dashboard, []},
  drivers: [
    [
      module: Scenic.Driver.Local,
      window: [
        title: "Dashboard"
      ],
      on_close: :stop_system
    ]
  ]

config :pomodoro, Pomodoro.Repo,
  database: "priv/pomodoro_database.db",
  migration_primary_key: [type: :binary_id],
  journal_mode: :wal,
  cache_size: -64000,
  temp_store: :memory,
  pool_size: 1

config :pomodoro, sound_directory: "deps/pomodoro/priv/sounds"

config :launcher, auto_refresh: true

config :tzdata, :autoupdate, :disabled
config :scenic, :assets, module: PianoUi.Assets

config :logger, backends: [RingLogger]

# You can also configure `RingLogger.Client` options to be used
# with every client by default
config :logger, RingLogger,
  format: "[$level] $message\n",
  level: :debug

case Mix.env() do
  :dev ->
    config :exsync,
      reload_timeout: 200,
      reload_callback: {ScenicLiveReload, :reload_current_scene, []}

  :test ->
    config :piano_ui, libcluster_hosts: []

  _ ->
    nil
end
