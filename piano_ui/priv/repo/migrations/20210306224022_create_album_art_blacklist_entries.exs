defmodule PianoUi.Repo.Migrations.CreateAlbumArtBlacklistEntries do
  use Ecto.Migration

  def change do
    create table(:album_art_blacklist_entries) do
      add :album_name, :text, null: false
      timestamps()
    end
  end
end
