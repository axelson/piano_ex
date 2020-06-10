defmodule Mix.Tasks.PianoEx.Init do
  @moduledoc """
  Helps with initial pianobar setup
  """
  use Mix.Task
  use Boundary, classify_to: PianoCtl

  @shortdoc "Initialize pianobar"
  def run(_) do
    PianoCtl.Initializer.init()
  end
end
