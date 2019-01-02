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
      |> render_text("", id: :title_text, t: {label_width, 0})
      |> render_label.("Artist: ", :artist_label, @default_font_size * 3)
      |> render_text("", id: :artist_text, t: {label_width, @default_font_size * 3})
      |> push_graph()

    Task.start(fn -> show_example() end)

    {:ok, %State{graph: initial_graph}}
  end

  def handle_cast({:update_song, song_description_attrs}, state) do
    %State{graph: graph} = state
    song_description = PlayUi.SongDescription.new(song_description_attrs)
    IO.inspect(song_description, label: "song_description")

    graph =
      graph
      |> Graph.modify(:title_text, gen_render_text(song_description.title))
      |> Graph.modify(:artist_text, gen_render_text(song_description.artist))
      |> push_graph()

    IO.inspect(graph, label: "graph")

    state = %{state | graph: graph}

    {:noreply, state}
  end

  def show_example do
    description = %PlayUi.SongDescription{
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
    IO.inspect(attributes, label: "attributes")
    Scenic.Primitives.text(graph, text, attributes)
  end

  defp text_attributes(opts) do
    Keyword.merge(@default_text_attributes, opts)
  end
end
