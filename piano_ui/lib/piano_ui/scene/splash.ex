defmodule PianoUi.Scene.Splash do
  use Scenic.Scene

  @default_font_size 24
  @default_text_attributes [
    font_size: @default_font_size,
    text_align: :left_top,
    width: 100,
    fill: :white
  ]

  alias Scenic.Graph

  @graph Graph.build()

  defmodule State do
    defstruct [:graph]
  end

  def init(_, _opts) do
    Process.register(self(), __MODULE__)
    label_width = 80

    render_label = fn graph, text, id, height ->
      render_text(graph, text, id: id, t: {label_width, height}, text_align: :right_top)
    end

    initial_graph =
      @graph
      |> render_label.("Title: ", :title_label, 0)
      |> render_text("", id: :title_text, t: {label_width, 0}, width: 100)
      |> render_label.("Artist: ", :artist_label, @default_font_size * 3)
      |> render_text("", id: :artist_text, t: {label_width, @default_font_size * 3})

    case get_current_song() do
      {:ok, song} ->
        update_song(song)

      _ ->
        Task.start(fn -> show_example() end)
    end

    {:ok, %State{graph: initial_graph}, push: initial_graph}
  end

  def update_song(server \\ __MODULE__, song) do
    GenServer.cast(server, {:update_song, song})
  end

  defp get_current_song do
    :rpc.call(PianoUi.ctl_node(), PianoCtl, :get_current_song, [])
  end

  def handle_cast({:update_song, song}, state) do
    %State{graph: graph} = state

    graph =
      graph
      |> Graph.modify(:title_text, gen_render_text(song.title))
      |> Graph.modify(:artist_text, gen_render_text(song.artist))

    # IO.inspect(graph, label: "graph")

    state = %{state | graph: graph}

    {:noreply, state, push: graph}
  end

  def show_example do
    description = %PianoUi.SongDescription{
      artist: "Johann Strauss II",
      title:
        "An Der Schönen, Blauen Donau (On The Beautiful, Blue Danube), Waltz For Orchestra (With Chorus Ad Lib), Op. 314 (Rv 314)"
      # "Some text\r\nMore text"
      # title:
      #   "abcdefghijklmnopqrstuvwxyz1abcdefghijklmnopqrstuvwxyz2abcdefghijklmnopqrstuvwxyz3abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz\nabc"
    }

    GenServer.cast(__MODULE__, {:update_song, description})
  end

  defp gen_render_text(text, attributes \\ []) do
    fn graph ->
      render_text(graph, text, attributes)
    end
  end

  defp render_text(graph, text, attributes) do
    attributes = text_attributes(attributes)
    # IO.inspect(attributes, label: "attributes")
    Scenic.Primitives.text(graph, text, attributes)
  end

  defp text_attributes(opts) do
    Keyword.merge(@default_text_attributes, opts)
  end
end
