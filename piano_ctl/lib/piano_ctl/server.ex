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
    end
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def input(server \\ __MODULE__, input) do
    GenServer.cast(server, {:input, input})
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
        print_event(event)
        notify_ui(event)
        state = %State{state | parser_state: parser_state}
        {:noreply, state}

      {:ok, :in_progress, parser_state} ->
        state = %State{state | parser_state: parser_state}
        {:noreply, state}
    end
  end

  defp print_event(%PianoParser.Event{} = event) do
    %PianoParser.Event{event_name: event_name, title: title, artist: artist, album: album} = event
    IO.puts("\nevent: #{event_name}")
    IO.puts("#{title} by #{artist} on #{album}")
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
