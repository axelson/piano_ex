defmodule PianoUi do
  @moduledoc """
  Documentation for PianoUi.
  """

  use Boundary, deps: [PianoCtl, ScenicContrib], exports: []
  require Logger

  def ctl_node, do: Application.fetch_env!(:piano_ui, :ctl_node)

  def remote_cmd(command) do
    Logger.info("Running remote command: #{inspect command}")
    Node.list()
    |> Enum.each(fn node ->
      :rpc.call(node, PianoCtl.Server, :cmd, [command])
    end)
  end
end
