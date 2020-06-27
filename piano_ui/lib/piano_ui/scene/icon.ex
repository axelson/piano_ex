defmodule PianoUi.Scene.Icon do
  use Scenic.Component, has_children: false

  alias Scenic.Graph

  defmodule State do
    defstruct []
  end

  @impl Scenic.Component
  def verify(data), do: {:ok, data}

  @impl Scenic.Scene
  def init(opts, scenic_opts) do
    filename = Keyword.get(opts, :filename)
    path = :code.priv_dir(:piano_ui) |> Path.join("/#{filename}")

    # This is a little hacky. Scenic would prefer us to build the hash at
    # compile time which we could do but it would require creating a macro
    hash = Scenic.Cache.Support.Hash.file!(path, :sha)
    {:ok, ^hash} = Scenic.Cache.Static.Texture.load(path, hash)

    graph =
      Graph.build()
      |> Scenic.Primitives.rect(
        {100, 100},
        fill: {:image, hash}
      )

    state = %State{}

    {:ok, state, push: graph}
  end
end
