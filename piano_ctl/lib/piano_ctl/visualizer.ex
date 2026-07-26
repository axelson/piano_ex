defmodule PianoCtl.Visualizer do
  @moduledoc """
  Responsible for visualizing the current state
  """

  alias PianoCtl.Models.Song

  def show(%Song{} = song) do
    pubsub = Application.fetch_env!(:piano_ctl, :pubsub)
    topic = Application.fetch_env!(:piano_ctl, :song_topic)
    Phoenix.PubSub.broadcast(pubsub, topic, {:song_started, song})
  end
end
