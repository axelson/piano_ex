defmodule PianoUi.Repo do
  use Ecto.Repo, otp_app: :piano_ui, adapter: Ecto.Adapters.Exqlite
end
