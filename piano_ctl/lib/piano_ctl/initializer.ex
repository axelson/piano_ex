defmodule PianoCtl.Initializer do
  @moduledoc """
  Initializes Pianobar to receive instruction. Typically called from a mix task.
  """

  use GenServer, restart: :temporary

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  @impl GenServer
  def init([]) do
    _ = make_input_fifo()
    _ = make_control_fifo()
    PianoCtl.Notifier.create_script()

    {:ok, []}
  end

  def make_input_fifo do
    System.cmd("mkfifo", [PianoCtl.Config.input_pipe_path()], stderr_to_stdout: true)
  end

  def make_control_fifo do
    System.cmd("mkfifo", [PianoCtl.Config.control_pipe_path()], stderr_to_stdout: true)
  end
end
