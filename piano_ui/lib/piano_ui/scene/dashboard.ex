defmodule PianoUi.Scene.Dashboard do
  use Scenic.Scene

  @default_font_size 24
  @default_text_attributes [
    font_size: 13,
    text_align: :left,
    text_base: :top,
    width: 100,
    fill: :white
  ]

  @album_art "album_art"
  @album_art_width 500
  @album_art_height 500
  @album_art_translate {35, 35}

  @refresh_rate round(1_000 / 30)

  require Logger

  alias Scenic.Graph
  alias Scenic.ViewPort
  alias PianoCtl.Models.Song
  alias PianoUi.FileCache

  @graph Graph.build()

  defmodule State do
    defstruct [:graph]
  end

  @impl Scenic.Scene
  def init(scene, opts, _scenic_opts) do
    # FIXME: This probably indicates a race condition and should instead happen via Scenic.PubSub
    Process.register(self(), __MODULE__)
    refresh = Keyword.get(opts, :refresh, false)
    pomodoro_timer_pid = Keyword.get(opts, :pomodoro_timer_pid)
    %Scenic.ViewPort{size: {screen_width, screen_height}} = scene.viewport

    if refresh do
      schedule_refresh()
    end

    render_label = fn graph, text, id, height ->
      render_text(graph, text,
        id: id,
        t: {126, 35 + height},
        font_size: 8,
        text_align: :left,
        text_base: :top
      )
    end

    render_label_text = fn graph, text, id, height ->
      render_text(graph, text,
        id: id,
        t: {165, 35 + height},
        font_size: @default_font_size,
        text_align: :left,
        text_base: :top
      )
    end

    line_height = @default_font_size * 1.2

    mini_timer_t = {595, 69}
    semaphore_t = {212, 295}

    initial_graph =
      @graph
      |> Scenic.Primitives.rect({screen_width, screen_height},
        fill: {:image, {:piano_ui, "images/dashboard_background.png"}}
      )
      # Title
      |> render_label.("TITLE", :title_label, line_height * 0)
      |> render_label_text.("", :title_text, line_height * 0)
      # Artist
      |> render_label.("ARTIST", :artist_label, line_height * 2)
      |> render_label_text.("", :artist_text, line_height * 2)
      # Album
      |> render_label.("ALBUM", :album_label, line_height * 3)
      |> render_label_text.("", :album_text, line_height * 3)
      |> render_empty_icon()
      |> PianoUi.Scene.MusicControls.add_to_graph(
        t: {35, 168},
        space_between: 58
      )
      |> PomodoroUi.Scene.MiniComponent.add_to_graph(
        [
          t: mini_timer_t
        ]
        |> maybe_add_pomodoro_timer_pid(pomodoro_timer_pid),
        scale: 1.0,
        pin: mini_timer_t
      )
      |> PianoUi.SemaphoreDisplay.add_to_graph(t: semaphore_t)
      |> Launcher.HiddenHomeButton.add_to_graph([])

    case get_current_song() do
      {:ok, song} ->
        update_song(song)

      _ ->
        nil
    end

    state = %State{graph: initial_graph}

    scene =
      scene
      |> assign(:state, state)
      |> push_graph(initial_graph)

    {:ok, scene}
  end

  defp maybe_add_pomodoro_timer_pid(opts, nil), do: opts

  defp maybe_add_pomodoro_timer_pid(opts, pomodoro_timer_pid) do
    Keyword.put(opts, :pomodoro_timer_pid, pomodoro_timer_pid)
  end

  def update_song(server \\ __MODULE__, song) do
    GenServer.cast(server, {:update_song, song})
  end

  defp get_current_song do
    Node.list()
    |> Enum.reduce_while(nil, fn node, _acc ->
      Logger.info("Getting song from node #{inspect(node)}")

      try do
        case :rpc.call(node, PianoCtl, :get_current_song, []) do
          nil -> {:cont, nil}
          {:ok, song} -> {:halt, {:ok, song}}
        end
      rescue
        _ -> {:cont, nil}
      end
    end)
  end

  @impl GenServer
  def handle_cast({:update_song, nil}, scene) do
    {:noreply, scene}
  end

  def handle_cast({:update_song, song}, scene) do
    state = scene.assigns.state
    %State{graph: graph} = state

    Logger.info("Displaying new song: #{inspect(song)}")

    graph =
      if PianoUi.AlbumArtBlacklist.banned?(song.album) do
        render_empty_icon(graph)
      else
        start_download_cover_art(song)
        graph
      end

    graph =
      graph
      |> Graph.modify(:title_text, gen_render_text(song.title))
      |> Graph.modify(:artist_text, gen_render_text(song.artist))
      |> Graph.modify(:album_text, gen_render_text(song.album))

    state = %{state | graph: graph}

    scene =
      scene
      |> assign(:state, state)
      |> push_graph(graph)

    {:noreply, scene}
  end

  @impl GenServer
  def handle_info({:downloaded_cover_art, image_binary}, scene) do
    state = scene.assigns.state
    %State{graph: graph} = state

    with {:ok, img} <- Scenic.Assets.Stream.Image.from_binary(image_binary),
         :ok <- Scenic.Assets.Stream.put(@album_art, img) do
      width = @album_art_width
      height = @album_art_height

      graph =
        Scenic.Primitives.rect(graph, {width, height},
          id: :album_art,
          fill: {:stream, @album_art},
          t: @album_art_translate,
          pin: {1, 1},
          s: 75 / @album_art_height
        )
        |> Graph.delete(:empty_icon)

      state = %State{state | graph: graph}

      scene =
        scene
        |> assign(:state, state)
        |> push_graph(graph)

      {:noreply, scene}
    else
      error ->
        Logger.error("Error downloading cover art: #{inspect(error)}")

        {:noreply, state}
    end
  end

  def handle_info(:refresh, scene) do
    schedule_refresh()
    scene = push_graph(scene, scene.assigns.state.graph)
    {:noreply, scene}
  end

  @impl Scenic.Scene
  def handle_input({:cursor_button, {:btn_left, 1, _, _}}, %{id: :album_art}, scene) do
    state = scene.assigns.state
    %State{graph: graph} = state

    graph =
      graph
      |> render_empty_icon()
      |> render_ban_button()
      |> Graph.delete(:album_art)

    state = %State{state | graph: graph}

    scene =
      scene
      |> assign(:state, state)
      |> push_graph(graph)

    {:noreply, scene}
  end

  # def handle_input(_input, _context, scene), do: {:noreply, scene}
  def handle_input(input, _context, scene) do
    Logger.warn("Ignoring input: #{inspect(input)}")
    {:noreply, scene}
  end

  @impl Scenic.Scene
  def handle_event({:click, :btn_ban_album_art}, _from, scene) do
    case get_current_song() do
      {:ok, song} ->
        Logger.warn("Banned! #{song.album}")

        PianoUi.AlbumArtBlacklist.ban(song.album)

      _ ->
        nil
    end

    {:noreply, scene}
  end

  defp start_download_cover_art(%Song{cover_art_url: nil}), do: nil
  defp start_download_cover_art(%Song{cover_art_url: ""}), do: nil

  defp start_download_cover_art(%Song{cover_art_url: cover_art_url})
       when not is_nil(cover_art_url) do
    parent = self()
    cover_art_url = PianoUi.CoverArtUrl.adjust_size(cover_art_url)

    if FileCache.has?(cover_art_url) do
      {:ok, body} = FileCache.read(cover_art_url)
      Logger.debug("Read from cache: #{cover_art_url}")

      send(parent, {:downloaded_cover_art, body})
    else
      Task.start_link(fn ->
        Logger.debug("downloading: #{inspect(cover_art_url)}")

        case Finch.build(:get, cover_art_url) |> Finch.request(MyFinch) do
          {:ok, %Finch.Response{status: 200, body: body}} ->
            Logger.info("Successfully downloaded cover art for #{cover_art_url}")
            send(parent, {:downloaded_cover_art, body})

            FileCache.put(cover_art_url, body)

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

  defp render_empty_icon(graph) do
    # FIXME: This doesn't take exactly the same space as the actual album art
    graph
    |> ScenicContrib.IconComponent.add_to_graph(
      [
        icon: PianoUi.Icons.icon(:empty_song),
        width: @album_art_width,
        height: @album_art_height
      ],
      id: :empty_icon,
      t: @album_art_translate,
      p: {1, 1},
      s: 75 / @album_art_height
    )
  end

  defp render_ban_button(graph) do
    graph
    |> Scenic.Components.button("Ban",
      id: :btn_ban_album_art,
      t: {15, 410},
      button_font_size: @default_font_size
    )
  end

  defp text_attributes(opts) do
    Keyword.merge(@default_text_attributes, opts)
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_rate)
  end
end
