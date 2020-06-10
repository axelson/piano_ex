defmodule PianoCtl do
  @moduledoc """
  Control pianobar from Elixir

  Architecture for reading:

  pianobar -> event_cmd (bash) -> input.pipe -> PianoCtl.PianoInputReader

  Architecuture for writing:

  PianoCtl.CommandRunner -> pianobar ctl pipe -> pianobar
  """

  use Boundary, deps: [], exports: []

  defdelegate cmd(command), to: PianoCtl.CommandRunner

  defdelegate get_current_song, to: PianoCtl.Server

  def config_folder, do: "#{System.user_home!()}/.config/pianobar"

  def ui_node, do: :ui@localhost
end
