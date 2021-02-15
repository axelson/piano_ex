use Mix.Config

ctl_node =
  case System.get_env("CTL_NODE") do
    nil -> nil
    node -> String.to_atom(node)
  end

config :piano_ui, :ctl_node, ctl_node
config :piano_ui, libcluster_hosts: [ctl_node]
config :piano_ui, :album_cache_dir, System.tmp_dir!() <> "/piano_ex_album_art/"

config :piano_ui, :viewport, %{
  name: :main_viewport,
  size: {800, 480},
  default_scene: {PianoUi.Scene.Splash, nil},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "Piano"]
    }
  ]
}

case Mix.env() do
  :dev ->
    config :exsync,
      reload_timeout: 50,
      reload_callback: {ScenicLiveReload, :reload_current_scene, []}

  :test ->
    config :piano_ui, libcluster_hosts: []

  _ ->
    nil
end
