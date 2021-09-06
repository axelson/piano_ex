defmodule PianoUi.Assets do
  use Scenic.Assets.Static,
    otp_app: :piano_ui,
    sources: [
      "assets",
      {:scenic, "deps/scenic/assets"}
    ],
    alias: [
      roboto: {:scenic, "fonts/roboto.ttf"}
    ]

  def asset_path, do:
    Path.join([__DIR__, "..", "..", "assets"]) |> Path.expand()
end
