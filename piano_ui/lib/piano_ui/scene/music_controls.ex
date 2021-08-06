defmodule PianoUi.Scene.MusicControls do
  use Scenic.Component

  alias Scenic.Graph
  alias PianoUi.Icons

  @impl Scenic.Component
  def validate(data), do: {:ok, data}

  @impl Scenic.Scene
  def init(scene, opts, _scenic_opts) do
    {base_x, base_y} = Keyword.get(opts, :t)
    space_between = Keyword.get(opts, :space_between)

    graph =
      Graph.build()
      |> ScenicContrib.IconComponent.add_to_graph(
        [
          icon: Icons.icon(:stop),
          on_press_icon: Icons.icon(:stop_pressed),
          on_click: &on_stop/0
        ],
        id: :btn_stop,
        t: {base_x, base_y}
      )
      |> ScenicContrib.IconComponent.add_to_graph(
        [
          icon: Icons.icon(:play),
          on_press_icon: Icons.icon(:play_pressed),
          on_click: &on_play/0
        ],
        id: :btn_play,
        t: {base_x + space_between, base_y}
      )
      |> ScenicContrib.IconComponent.add_to_graph(
        [
          icon: Icons.icon(:next),
          on_press_icon: Icons.icon(:next_pressed),
          on_click: &on_next/0
        ],
        id: :btn_next,
        t: {base_x + space_between * 2, base_y}
      )

    scene = push_graph(scene, graph)

    {:ok, scene}
  end

  defp on_play, do: PianoUi.remote_cmd(:play)
  defp on_stop, do: PianoUi.remote_cmd(:stop)
  defp on_next, do: PianoUi.remote_cmd(:next)
end
