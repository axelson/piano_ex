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

  def remote_cmd(command) do
    Node.list()
    |> Enum.each(fn node ->
      Node.spawn_link(node, fn ->
        PianoCtl.cmd(command)
      end)
    end)
  end
end
