defmodule PianoUi do
  @moduledoc """
  Documentation for PianoUi.
  """

  use Boundary, deps: [PianoCtl, ScenicContrib], exports: []

  def ctl_node, do: Application.fetch_env!(:piano_ui, :ctl_node)

  def remote_cmd(command) do
    Node.list()
    |> Enum.each(fn node ->
      :rpc.call(node, PianoCtl.Server, :cmd, [command])
    end)
  end
end
