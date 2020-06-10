use Mix.Config

config :piano_ui, :ctl_node, :ctl@localhost

config :piano_ui, :viewport, %{
  name: :main_viewport,
  size: {500, 500},
  # size: {500 * 3, 500 * 3},
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

  _ ->
    nil
end
