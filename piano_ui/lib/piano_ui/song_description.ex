defmodule PlayUi.SongDescription do
  defstruct [
    :title,
    :artist
  ]

  def new(%{title: title, artist: artist}) do
    %__MODULE__{
      title: title,
      artist: artist
    }
  end
end
