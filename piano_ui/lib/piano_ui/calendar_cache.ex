defmodule PianoUi.CalendarCache do
  @moduledoc """
  Fetches and parses calendars

  Supports ical format

  Note: Would be more performant with ETS but a simple GenServer is fine for now
  """

  use GenServer
  require Logger

  @sensor :calendar

  defmodule State do
    defstruct [:events, :published]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def next_event do
    GenServer.call(__MODULE__, :next_event)
  end

  def refresh do
    send(__MODULE__, :fetch_calendar)
  end

  @impl GenServer
  def init(_opts) do
    Logger.info("Calendar cache start!")
    Scenic.Sensor.register(@sensor, "1", "Calendar")

    schedule_fetch(0)
    {:ok, %State{events: [], published: false}}
  end

  @impl GenServer
  def handle_call(:next_event, _from, state) do
    next_event = get_next_event(state)

    {:reply, next_event, state}
  end

  @impl GenServer
  def handle_info(:fetch_calendar, state) do
    events =
      PianoUi.CalendarFetcher.read_calendars(calendar_urls())
      |> Enum.sort_by(& &1.dtstart, DateTime)
      |> filter_all_day_events()

    state =
      %State{state | events: events}
      |> maybe_first_publish()

    schedule_fetch()

    {:noreply, state}
  end

  def handle_info(:publish, scene) do
    event = get_next_event(scene)

    Scenic.Sensor.publish(@sensor, event)

    schedule_publish()
    {:noreply, scene}
  end

  def filter_all_day_events(events) do
    Enum.reject(events, fn event ->
      start = event.dtstart
      finish = event.dtend

      if start && finish do
        DateTime.diff(finish, start) == 86_400 && start.hour == 0 && start.minute == 0 &&
          start.second == 0
      else
        false
      end
    end)
  end

  defp get_next_event(state) do
    now = DateTime.utc_now()

    Enum.find(state.events, fn event ->
      DateTime.compare(event.dtstart, now) == :gt
    end)
    # |> DataTracer.store(key: "event", log?: false)
  end

  defp maybe_first_publish(%State{published: true} = state), do: state

  defp maybe_first_publish(%State{} = state) do
    schedule_publish(100)
    %State{state | published: true}
  end

  defp schedule_fetch(timeout \\ :timer.minutes(5)),
    do: Process.send_after(self(), :fetch_calendar, timeout)

  defp schedule_publish(timeout \\ 10_000), do: Process.send_after(self(), :publish, timeout)

  defp calendar_urls, do: Application.get_env(:piano_ui, :calendar_urls, [])
end
