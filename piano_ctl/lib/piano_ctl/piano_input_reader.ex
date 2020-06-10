defmodule PianoCtl.PianoInputReader do
  @moduledoc """
  Reads from the input pipe and sends the message on

  Infinitely loop on reading input.pipe

  Must not fail in reading from the pipe because failing to read will result in
  pianobar stopping playback.
  """

  use GenServer
  require Logger

  # TODO:
  # [ ] Record the currently playing song in the process state (unless that should be in a different process)

  def start_link(state) do
    IO.inspect(self(), label: "start_link self()")
    GenServer.start_link(__MODULE__, state)
  end

  @impl GenServer
  def init(_args) do
    # The first time this needs to be about 1000 for some reason
    schedule_work(1000)
    {:ok, :default}
  end

  @impl GenServer
  def handle_info(:read_pipe, state) do
    case File.read(input_file()) do
      {:ok, input} ->
        PianoCtl.Server.input(input)

      {:error, error} ->
        Logger.error("Unable to read from pipe: #{inspect(error)}")
    end

    schedule_work(0)
    {:noreply, state}
  end

  defp schedule_work(delay \\ 1000) do
    Process.send_after(self(), :read_pipe, delay)
  end

  defp input_file do
    Path.join([__DIR__, "../../../input.pipe"])
  end
end
