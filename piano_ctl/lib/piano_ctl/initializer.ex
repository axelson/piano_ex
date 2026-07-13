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
    make_fifo(PianoCtl.Config.input_pipe_path())
  end

  def make_control_fifo do
    make_fifo(PianoCtl.Config.control_pipe_path())
  end

  defp make_fifo(path) do
    if File.exists?(path) do
      {:already_exists, path}
    else
      case System.find_executable("mkfifo") do
        nil -> System.cmd("mknod", [path, "p"], stderr_to_stdout: true)
        _ -> System.cmd("mkfifo", [path], stderr_to_stdout: true)
      end
    end
  end
end
