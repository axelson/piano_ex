defmodule PianoCtl do
  @moduledoc """
  Control pianobar from Elixir

  Architecture for reading:

  pianobar -> event_cmd (bash) -> input.pipe -> PianoCtl.PianoInputReader

  Architecuture for writing:

  PianoCtl.CommandRunner -> pianobar ctl pipe -> pianobar
  """

  use Boundary, deps: [], exports: [Models.Song, PianoInputReader]

  defdelegate cmd(command), to: PianoCtl.CommandRunner
  defdelegate change_station(station_number), to: PianoCtl.CommandRunner

  defdelegate get_current_song, to: PianoCtl.Server
  defdelegate list_stations, to: PianoCtl.Server

  def print_stations do
    list_stations()
    |> Enum.each(fn {n, name} -> IO.puts("#{n} - #{name}") end)
  end
end
