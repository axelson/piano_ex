defmodule PianoUi.Scene.Icon do
  use Scenic.Component, has_children: true

  alias Scenic.Graph

  defmodule State do
    defstruct [:hash, :on_press_hash, :on_click, depressed: false]
  end

  @impl Scenic.Component
  def verify(data), do: {:ok, data}

  @impl Scenic.Scene
  def init(opts, _scenic_opts) do
    filename = Keyword.get(opts, :filename)
    on_press_filename = Keyword.get(opts, :on_press_filename)

    on_click = Keyword.get(opts, :on_click)

    path = :code.priv_dir(:piano_ui) |> Path.join("/#{filename}")
    on_press_path = :code.priv_dir(:piano_ui) |> Path.join("/#{on_press_filename}")

    # This is a little hacky. Scenic would prefer us to build the hash at
    # compile time which we could do but it would require creating a macro
    hash = Scenic.Cache.Support.Hash.file!(path, :sha)
    {:ok, ^hash} = Scenic.Cache.Static.Texture.load(path, hash, scope: :global)

    on_press_hash = Scenic.Cache.Support.Hash.file!(on_press_path, :sha)

    {:ok, ^on_press_hash} =
      Scenic.Cache.Static.Texture.load(on_press_path, on_press_hash, scope: :global)

    graph = render(hash, on_press_hash, false)

    state = %State{hash: hash, on_press_hash: on_press_hash, on_click: on_click}

    {:ok, state, push: graph}
  end

  @impl Scenic.Scene
  def handle_input({:cursor_button, {_, :press, _, _}}, _context, state) do
    %State{hash: hash, on_press_hash: on_press_hash, on_click: on_click} = state
    if on_click, do: on_click.()

    graph = render(hash, on_press_hash, true)

    # I would've preferred to let these events bubble up to the MusicControls
    # component but {:cont, state} here appears to result in an infinite loop

    {:noreply, state, push: graph}
  end

  def handle_input({:cursor_button, {_, :release, _, _}}, _context, state) do
    %State{hash: hash, on_press_hash: on_press_hash} = state
    graph = render(hash, on_press_hash, false)
    {:noreply, state, push: graph}
  end

  def handle_input(_input, _context, state) do
    {:noreply, state}
  end

  defp render(hash, on_press_hash, depressed) do
    fill =
      if depressed do
        {:image, on_press_hash}
      else
        {:image, hash}
      end

    Graph.build()
    |> Scenic.Primitives.rect(
      {100, 100},
      fill: fill
    )
  end
end
