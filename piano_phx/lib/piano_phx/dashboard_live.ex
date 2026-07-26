defmodule PianoPhx.DashboardLive do
  use PianoPhx, :live_view

  @topic Application.compile_env!(:piano_ctl, :song_topic)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PianoPhx.PubSub, @topic)
    end

    song = if connected?(socket), do: fetch_current_song(), else: nil

    {:ok, assign(socket, song: song)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-6 p-8">
      <div class="flex items-start gap-6">
        <div class="w-48 h-48 shrink-0">
          <img
            :if={@song && @song.cover_art_url}
            src={@song.cover_art_url}
            class="w-full h-full object-cover rounded-lg"
          />
          <div
            :if={!@song || !@song.cover_art_url}
            class="w-full h-full bg-base-300 rounded-lg flex items-center justify-center"
          >
            <span class="text-base-content/50 text-4xl">♪</span>
          </div>
        </div>

        <div :if={@song} class="flex flex-col gap-1">
          <h2 class="text-xl font-bold">{@song.title}</h2>
          <p class="text-base-content/70">{@song.artist}</p>
          <p class="text-base-content/50 text-sm">{@song.album}</p>
        </div>

        <div :if={!@song} class="flex flex-col gap-1">
          <p class="text-base-content/50">No song playing</p>
        </div>
      </div>

      <div class="flex gap-4">
        <button phx-click="stop" class="btn btn-circle btn-lg">
          <.icon name="hero-stop-solid" class="w-6 h-6" />
        </button>
        <button phx-click="play" class="btn btn-circle btn-lg btn-primary">
          <.icon name="hero-play-solid" class="w-6 h-6" />
        </button>
        <button phx-click="next" class="btn btn-circle btn-lg">
          <.icon name="hero-forward-solid" class="w-6 h-6" />
        </button>
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
