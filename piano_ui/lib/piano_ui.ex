defmodule PianoUi do
  @moduledoc """
  Documentation for PianoUi.
  """

  use Boundary, deps: [PianoCtl, ScenicContrib], exports: []
  require Logger

  def ctl_node, do: Application.fetch_env!(:piano_ui, :ctl_node)

  def remote_cmd(command) do
    Logger.info("Running remote command: #{inspect(command)}")

    Node.list()
    |> Enum.each(fn node ->
      Logger.info("Sending command to node #{inspect(node)}")

      try do
        :rpc.call(node, PianoCtl.Server, :cmd, [command])
      rescue
        _ -> nil
      end
    end)
  end

  def start_meeting do
    with mod when not is_nil(mod) <- Application.get_env(:piano_ui, :meeting_module) do
      mod.start_meeting()
    end
  end

  def finish_meeting do
    with mod when not is_nil(mod) <- Application.get_env(:piano_ui, :meeting_module) do
      mod.finish_meeting()
    end
  end
end
