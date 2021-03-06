defmodule PianoUi.Scene.MusicControls do
  use Scenic.Component

  alias Scenic.Graph

  defmodule State do
    defstruct []
  end

  @impl Scenic.Component
  def verify(data), do: {:ok, data}

  @impl Scenic.Scene
  def init(opts, _scenic_opts) do
    {base_x, base_y} = Keyword.get(opts, :t)
    space_between = Keyword.get(opts, :space_between)

    graph =
      Graph.build()
      |> ScenicContrib.IconComponent.add_to_graph(
        [
          icon: PianoUi.StopIcon,
          on_press_icon: PianoUi.StopPressedIcon,
          on_click: &on_stop/0
        ],
        id: :btn_stop,
        t: {base_x, base_y}
      )
      |> ScenicContrib.IconComponent.add_to_graph(
        [
          icon: PianoUi.PlayIcon,
          on_press_icon: PianoUi.PlayPressedIcon,
          on_click: &on_play/0
        ],
        id: :btn_play,
        t: {base_x + space_between, base_y}
      )
      |> ScenicContrib.IconComponent.add_to_graph(
        [
          icon: PianoUi.NextIcon,
          on_press_icon: PianoUi.NextPressedIcon,
          on_click: &on_next/0
        ],
        id: :btn_next,
        t: {base_x + space_between * 2, base_y}
      )

    state = %State{}
    {:ok, state, push: graph}
  end

  defp on_play, do: PianoUi.remote_cmd(:play)
  defp on_stop, do: PianoUi.remote_cmd(:stop)
  defp on_next, do: PianoUi.remote_cmd(:next)
end
