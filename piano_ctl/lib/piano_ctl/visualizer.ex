defmodule PianoCtl.Visualizer do
  @moduledoc """
  Responsible for visualizing the current state

  Currently operates by sending distributed messages to the other node
  """

  alias PianoCtl.Models.Song

  def show(%Song{} = song) do
    node = PianoCtl.ui_node()
    Node.spawn(node, GenServer, :cast, [PianoUi.Scene.Splash, {:update_song, song}])
  end
end
