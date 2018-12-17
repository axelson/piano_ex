defmodule PianoCtl do
  @moduledoc """
  Control pianobar from Elixir

  Architecture for reading:

  pianobar -> event_cmd (bash) -> input.pipe -> PianoCtl.PianoInputReader

  Architecuture for writing:

  PianoCtl.CommandRunner -> pianobar ctl pipe -> pianobar
  """

  defdelegate cmd(command), to: PianoCtl.CommandRunner

  def config_folder, do: "#{System.user_home!()}/.config/pianobar"
end
