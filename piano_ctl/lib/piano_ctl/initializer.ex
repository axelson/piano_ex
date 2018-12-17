defmodule PianoCtl.Initializer do
  @moduledoc """
  Initializes Pianobar to receive instruction. Typically called from a mix task.
  """

  def init do
    IO.puts "Initializing"
    make_control_fifo()
  end

  def make_control_fifo do
    System.cmd("mkfifo", ["#{PianoCtl.config_folder()}/ctl"])
  end

  def add_event_command do
    # no-op for now
    :ok
  end
end
