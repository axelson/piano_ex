defmodule PianoPhx.DashboardLive do
  use PianoPhx, :live_view

  @topic Application.compile_env!(:piano_ctl, :song_topic)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PianoPhx.PubSub, @topic)
    end

    song = if connected?(socket), do: fetch_current_song(), else: nil

    {:ok, assign(socket, song: song, show_stations: false, stations: [])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-6">
      <div class="w-[300px] h-[300px] shrink-0">
        <img
          :if={@song && @song.cover_art_url}
          src={@song.cover_art_url}
          class="w-full h-full object-cover rounded-lg shadow-lg"
        />
        <div
          :if={!@song || !@song.cover_art_url}
          class="w-full h-full bg-base-300 rounded-lg flex items-center justify-center"
        >
          <span class="text-base-content/50 text-6xl">♪</span>
        </div>
      </div>

      <div :if={@song} class="text-center space-y-1">
        <h2 class="text-2xl font-bold">{@song.title}</h2>
        <p class="text-lg text-base-content/70">{@song.artist}</p>
        <p class="text-sm text-base-content/50">{@song.album}</p>
      </div>

      <div :if={!@song} class="text-center">
        <p class="text-base-content/50">No song playing</p>
      </div>

      <div class="flex items-center gap-4">
        <button phx-click="stop" class="btn btn-circle btn-lg" aria-label="Stop">
          <.icon name="hero-stop-solid" class="size-6" />
        </button>
        <button phx-click="play" class="btn btn-circle btn-xl btn-primary" aria-label="Play">
          <.icon name="hero-play-solid" class="size-8" />
        </button>
        <button phx-click="next" class="btn btn-circle btn-lg" aria-label="Next">
          <.icon name="hero-forward-solid" class="size-6" />
        </button>
      </div>

      <button phx-click="toggle_stations" class="btn btn-outline btn-sm">
        <.icon name="hero-radio" class="size-4" />
        Change Station
      </button>

      <div :if={@show_stations} class="w-full max-w-sm">
        <ul class="menu menu-sm bg-base-200 rounded-box max-h-64 overflow-y-auto">
          <li :for={{number, name} <- @stations}>
            <button phx-click="select_station" phx-value-number={number}>{name}</button>
          </li>
          <li :if={@stations == []}>
            <span class="text-base-content/50">No stations available yet</span>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("play", _params, socket) do
    PianoCtl.Server.cmd(:play)
    {:noreply, socket}
  end

  def handle_event("stop", _params, socket) do
    PianoCtl.Server.cmd(:stop)
    {:noreply, socket}
  end

  def handle_event("next", _params, socket) do
    PianoCtl.Server.cmd(:next)
    {:noreply, socket}
  end

  def handle_event("toggle_stations", _params, socket) do
    if socket.assigns.show_stations do
      {:noreply, assign(socket, show_stations: false)}
    else
      stations = PianoCtl.list_stations()
      {:noreply, assign(socket, show_stations: true, stations: stations)}
    end
  end

  def handle_event("select_station", %{"number" => number}, socket) do
    PianoCtl.change_station(number)
    {:noreply, assign(socket, show_stations: false)}
  end

  @impl true
  def handle_info({:song_started, song}, socket) do
    {:noreply, assign(socket, song: song)}
  end

  defp fetch_current_song do
    case PianoCtl.get_current_song() do
      {:ok, song} -> song
      _ -> nil
    end
  end
end
