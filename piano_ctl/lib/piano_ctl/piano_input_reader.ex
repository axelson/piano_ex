defmodule PianoCtl.PianoInputReader do
  @moduledoc """
  Reads from the input pipe and sends the message on

  Infinitely loop on reading input.pipe
  """
  use GenServer

  # TODO:
  # [ ] Record the currently playing song in the process state (unless that should be in a different process)

  def start_link(state) do
    IO.inspect(self(), label: "start_link self()")
    GenServer.start_link(__MODULE__, state)
  end

  @impl GenServer
  def init(_args) do
    IO.puts "Input Reader Starting!"
    schedule_work()
    {:ok, :default}
  end

  @impl GenServer
  def handle_info({:read_pipe}, state) do
    case PianoCtl.PianoParser.read_file() do
      {:ok, record} ->
        %{event_name: event_name, title: title, cover_art: cover_art} = record
        IO.inspect(record, label: "record")
        PianoCtl.Visualizer.show(record)
        # GenServer.cast(PianoUi.Scene.Splash, {:update_title, title})
      {:error, _msg} ->
        Process.sleep(1000)
    end

    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    IO.puts "Scheduling"
    # The first time this needs to be about 1000 for some reason
    Process.send_after(self(), {:read_pipe}, 1000)
  end

  defp input_file, do: "/Users/jason/dev/piano_ex/input.pipe"
end
