defmodule PianoUi.AlbumArtBlacklistEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "album_art_blacklist_entries" do
    field :album_name, :string

    timestamps()
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:album_name])
    |> validate_required([:album_name])
  end
end
