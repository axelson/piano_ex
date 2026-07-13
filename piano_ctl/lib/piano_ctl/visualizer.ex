defmodule PianoCtl.Visualizer do
  @moduledoc """
  Responsible for visualizing the current state
  """

  alias PianoCtl.Models.Song

  def show(%Song{} = song) do
    PianoUi.Scene.Dashboard.update_song(song)
  end
end
