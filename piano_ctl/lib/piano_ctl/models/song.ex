defmodule PianoCtx.Models.Song do
  use TypedStruct

  typedstruct do
    field :title, String.t()
    field :album, String.t()
    field :cover_art_url, String.t()
  end
end
