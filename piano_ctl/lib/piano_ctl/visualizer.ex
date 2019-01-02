defmodule PianoCtl.Visualizer do
  @moduledoc """
  Responsible for visualizing the current state

  Currently operates by sending distributed messages to the other node
  """

  def show(record) do
    node = PianoCtl.ui_node()
    attrs = render_song_attributes(record)
    Node.spawn(node, GenServer, :cast, [PianoUi.Scene.Splash, {:update_song, attrs}])
  end

  defp render_song_attributes(%{title: title, artist: artist}) do
    %{title: title, artist: artist}
  end
end
