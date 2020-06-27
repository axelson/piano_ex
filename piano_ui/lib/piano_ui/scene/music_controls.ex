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
      |> PianoUi.Scene.Icon.add_to_graph([filename: "stop_icon.png"],
        id: :btn_stop,
        t: {base_x, base_y}
      )
      |> PianoUi.Scene.Icon.add_to_graph([filename: "play_icon.png"],
        id: :btn_play,
        t: {base_x + space_between, base_y}
      )
      |> PianoUi.Scene.Icon.add_to_graph([filename: "next_icon.png"],
        id: :btn_next,
        t: {base_x + space_between * 2, base_y}
      )

    state = %State{}
    {:ok, state, push: graph}
  end
end
