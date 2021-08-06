defmodule PianoUi.Icons do
  @icons %{
    stop: "images/stop.png",
    stop_pressed: "images/stop-selected.png",
    play: "images/play.png",
    play_pressed: "images/play-selected.png",
    next: "images/next.png",
    next_pressed: "images/next-selected.png",
    empty_song: "images/empty-song.jpg"
  }

  def icon(name), do: Map.get(@icons, name)
end
