defmodule PianoUi.AlbumArtBlacklist do
  alias PianoUi.AlbumArtBlacklistEntry
  alias PianoUi.Repo

  import Ecto.Query

  def ban(album_name) do
    %AlbumArtBlacklistEntry{}
    |> AlbumArtBlacklistEntry.changeset(%{"album_name" => album_name})
    |> Repo.insert()
  end

  def banned?(nil), do: false

  def banned?(album_name) do
    query = from e in AlbumArtBlacklistEntry, where: e.album_name == ^album_name
    Repo.exists?(query)
  end
end
