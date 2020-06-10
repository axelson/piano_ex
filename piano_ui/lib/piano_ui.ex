defmodule PianoUi do
  @moduledoc """
  Documentation for PianoUi.
  """

  use Boundary, deps: [PianoCtl], exports: []

  def ctl_node, do: Application.fetch_env!(:piano_ui, :ctl_node)
end
