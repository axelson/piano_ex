# TODO: Cleanup
# This is no longer run as a GenServer
defmodule PianoCtl.PianoInputReader do
  @moduledoc """
  Reads from the input pipe and sends the message on

  Infinitely loop on reading input.pipe

  Must not fail in reading from the pipe because failing to read will result in
  pianobar stopping playback.
  """

  use GenServer
  require Logger

  def start_link(state) do
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
    case read_pipe() do
      {:ok, input} ->
        PianoCtl.Server.input(input)

      {:error, error} ->
        Logger.error("Unable to read from pipe: #{inspect(error)}")
    end

    schedule_work(0)
    {:noreply, state}
  end

  # NOTE: This blocks all file I/O. A different approach should be used for named pipes
  defp read_pipe do
    File.read(PianoCtl.Config.input_pipe_path())
  end

  defp schedule_work(delay) do
    Process.send_after(self(), :read_pipe, delay)
  end

  def notify(input, _env_vars) do
    [event_name, input] = input

    PianoCtl.Server.input("#{event_name}\n")
    PianoCtl.Server.input("#{input}\n")
  end
end
