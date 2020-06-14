defmodule Mix.Tasks.PianoEx.Init do
  @moduledoc """
  Helps with initial pianobar setup. This script is optional since it is run on
  app start
  """
  use Mix.Task
  use Boundary, classify_to: PianoCtl

  @shortdoc "Initialize pianobar"
  def run(_) do
    PianoCtl.Initializer.init([])
  end
end
