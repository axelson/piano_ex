defmodule PianoUi.Scene.Splash do
  use Scenic.Scene

  @default_font_size 24
  @default_text_attributes [
    font_size: @default_font_size,
    text_align: :left_top,
    width: 100,
    fill: :white
  ]

  @refresh_rate round(1_000 / 30)

  require Logger

  alias Scenic.Graph
  alias PianoCtl.Models.Song
  alias PianoUi.FileCache

  @graph Graph.build()

  defmodule State do
    defstruct [:graph]
  end

  @impl Scenic.Scene
  def init(_, _opts) do
    # FIXME: This probably indicates a race condition and should instead happen via Scenic.Sensor
    Process.register(self(), __MODULE__)
    schedule_refresh()
    label_width = 70
    # FIXME: This should be 10 and still line up with the album art
    left_padding = 15

    render_label = fn graph, text, id, height ->
      render_text(graph, text, id: id, t: {left_padding, height}, text_align: :left_top)
    end

    line_height = @default_font_size * 1.2
    text_start = left_padding + label_width

    initial_graph =
      @graph
      # Title
      |> render_label.("Title: ", :title_label, line_height * 0)
      |> render_text("", id: :title_text, t: {text_start, line_height * 0}, width: 100)
      # Artist
      |> render_label.("Artist: ", :artist_label, line_height * 1)
      |> render_text("",
        id: :artist_text,
        t: {text_start, line_height * 1}
      )
      |> render_label.("Album: ", :album_label, line_height * 2)
      |> render_text("", id: :album_text, t: {text_start, line_height * 2}, width: 100)
      |> PianoUi.Scene.MusicControls.add_to_graph(
        t: {370, 365},
        space_between: 130
      )
      |> Launcher.HiddenHomeButton.add_to_graph([])

    case get_current_song() do
      {:ok, song} ->
        update_song(song)

      _ ->
        nil
    end

    {:ok, %State{graph: initial_graph}, push: initial_graph}
  end

  def update_song(server \\ __MODULE__, song) do
    GenServer.cast(server, {:update_song, song})
  end

  defp get_current_song do
    :rpc.call(PianoUi.ctl_node(), PianoCtl, :get_current_song, [])
  end

  @impl Scenic.Scene
  def handle_cast({:update_song, nil}, state) do
    {:noreply, state}
  end

  def handle_cast({:update_song, song}, state) do
    %State{graph: graph} = state

    Logger.info("Displaying new song: #{inspect(song)}")

    start_download_cover_art(song)

    graph =
      graph
      |> Graph.modify(:title_text, gen_render_text(song.title))
      |> Graph.modify(:artist_text, gen_render_text(song.artist))
      |> Graph.modify(:album_text, gen_render_text(song.album))

    state = %{state | graph: graph}

    {:noreply, state, push: graph}
  end

  @impl Scenic.Scene
  def handle_info({:downloaded_cover_art, image_binary}, state) do
    %State{graph: graph} = state

    with {1, {:ok, image_hash}} <- {1, Scenic.Cache.Support.Hash.binary(image_binary, :sha)},
         {2, {:ok, ^image_hash}} <-
           {2, Scenic.Cache.Static.Texture.put_new(image_hash, image_binary, :global)} do
      width = 500
      height = 500

      translate = {10, 117}

      graph =
        Scenic.Primitives.rect(graph, {width, height},
          fill: {:image, image_hash},
          t: translate,
          pin: translate,
          s: 0.6
        )

      state = %State{state | graph: graph}
      {:noreply, state, push: graph}
    else
      error ->
        Logger.error("Error downloading cover art: #{inspect(error)}")

        {:noreply, state}
    end
  end

  def handle_info(:refresh, state) do
    schedule_refresh()
    {:noreply, state, push: state.graph}
  end

  defp start_download_cover_art(%Song{cover_art_url: cover_art_url}) do
    parent = self()

    if FileCache.has?(cover_art_url) do
      {:ok, body} = FileCache.read(cover_art_url)
      Logger.debug("Read from cache: #{cover_art_url}")

      send(parent, {:downloaded_cover_art, body})
    else
      Task.start_link(fn ->
        Logger.debug("downloading: #{cover_art_url}")

        case Finch.build(:get, cover_art_url) |> Finch.request(MyFinch) do
          {:ok, %Finch.Response{status: 200, body: body}} ->
            Logger.info("Successfully downloaded cover art for #{cover_art_url}")
            send(parent, {:downloaded_cover_art, body})

            FileCache.put(cover_art_url, body)
            |> IO.inspect(label: "put_cover_art")

          err ->
            Logger.error("unable to download cover art. #{inspect(err)}")
        end
      end)
    end
  end

  defp start_download_cover_art(_), do: nil

  defp gen_render_text(text, attributes \\ []) do
    fn graph ->
      render_text(graph, text, attributes)
    end
  end

  defp render_text(graph, text, attributes) do
    attributes = text_attributes(attributes)
    Scenic.Primitives.text(graph, text, attributes)
  end

  defp text_attributes(opts) do
    Keyword.merge(@default_text_attributes, opts)
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_rate)
  end
end
