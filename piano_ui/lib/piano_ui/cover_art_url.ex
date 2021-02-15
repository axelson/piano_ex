defmodule PianoUi.CoverArtUrl do
  def adjust_size(url) do
    String.replace(url, ~r/\d+W_\d+H/, "500W_500H")
  end
end
