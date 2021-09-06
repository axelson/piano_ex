defmodule PianoUi.Icons do
  @icons %{
    stop: {:piano_ui, "images/stop.png"},
    stop_pressed: {:piano_ui, "images/stop-selected.png"},
    play: {:piano_ui, "images/play.png"},
    play_pressed: {:piano_ui, "images/play-selected.png"},
    next: {:piano_ui, "images/next.png"},
    next_pressed: {:piano_ui, "images/next-selected.png"},
    empty_song: {:piano_ui, "images/empty-song.jpg"}
  }

  def icon(name), do: Map.get(@icons, name)
end
