defmodule PianoCtl.Server do
  @moduledoc """
  Parses the input received from pianobar, then sends it to the visualization
  pipeline
  """

  use GenServer

  alias PianoCtl.PianoParser
  alias PianoCtl.Models

  defmodule State do
    use TypedStruct

    typedstruct do
      field :parser_state, PianoParser.state(), default: :empty
      field :current_song, Models.Song.t()
      field :updated_at, NaiveDateTime.t()
    end
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def input(server \\ __MODULE__, input) do
    GenServer.cast(server, {:input, input})
  end

  def cmd(server \\ __MODULE__, command) do
    GenServer.call(server, {:cmd, command})
  end

  def get_current_song(server \\ __MODULE__) do
    GenServer.call(server, :get_current_song)
  end

  @impl GenServer
  def init(_opts) do
    {:ok, %State{}}
  end

  @impl GenServer
  def handle_cast({:input, input}, state) do
    %State{parser_state: parser_state} = state

    case PianoParser.parse(parser_state, input) do
      {:ok, :event, event, parser_state} ->
        notify_ui(event)

        state =
          %State{state | parser_state: parser_state}
          |> update_state_for_event(event)

        {:noreply, state}

      {:ok, :in_progress, parser_state} ->
        state = %State{state | parser_state: parser_state}
        {:noreply, state}
    end
  end

  @impl GenServer
  def handle_call(:get_current_song, _from, state) do
    {:reply, do_get_current_song(state), state}
  end

  def handle_call({:cmd, command}, _from, state) do
    result = PianoCtl.cmd(command)
    {:reply, result, state}
  end

  defp update_state_for_event(state, %PianoParser.Event{event_name: "songstart"} = event) do
    song = Models.Song.from_event(event)
    now = NaiveDateTime.utc_now()

    %State{state | current_song: song, updated_at: now}
  end

  defp update_state_for_event(state, %PianoParser.Event{}), do: state

  defp do_get_current_song(%State{updated_at: nil}), do: nil

  defp do_get_current_song(%State{} = state) do
    now = NaiveDateTime.utc_now()

    if NaiveDateTime.diff(now, state.updated_at, :second) > 60 * 10 do
      nil
    else
      {:ok, state.current_song}
    end
  end

  defp notify_ui(event) do
    case event do
      %PianoParser.Event{event_name: "songstart"} ->
        Models.Song.from_event(event)
        |> PianoCtl.Visualizer.show()

      _ ->
        nil
    end
  end
end
