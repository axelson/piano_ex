defmodule PianoCtl.Models.Song do
  use TypedStruct

  alias PianoCtl.PianoParser.Event

  typedstruct do
    field :title, String.t()
    field :album, String.t()
    field :artist, String.t()
    field :cover_art_url, String.t()
  end

  def from_event(%Event{} = event) do
    %Event{
      title: title,
      album: album,
      artist: artist,
      cover_art: cover_art
    } = event

    %__MODULE__{
      title: title,
      album: album,
      artist: artist,
      cover_art_url: cover_art
    }
  end
end
