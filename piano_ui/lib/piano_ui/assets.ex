defmodule PianoUi.Assets do
  use Scenic.Assets.Static,
    otp_app: :piano_ui,
    sources: [
      "assets",
      {:pomodoro, PomodoroUi.Assets.asset_path()},
      {:scenic, "deps/scenic/assets"}
    ]

  def asset_path, do: Path.join([__DIR__, "..", "..", "assets"]) |> Path.expand()
end
