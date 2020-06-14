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
    add_event_command!()

    {:ok, []}
  end

  def make_input_fifo do
    System.cmd("mkfifo", [PianoCtl.Config.input_pipe_path()], stderr_to_stdout: true)
  end

  def make_control_fifo do
    System.cmd("mkfifo", [PianoCtl.Config.control_pipe_path()], stderr_to_stdout: true)
  end

  def add_event_command! do
    source = Path.join([__DIR__, "../../command.sh"])
    dest = PianoCtl.Config.event_command_path()
    File.cp!(source, dest)
  end
end
