defmodule PianoUi do
  @moduledoc """
  Documentation for PianoUi.
  """

  use Boundary, deps: [PianoCtl], exports: []

  def ctl_node, do: :ctl@localhost
end
