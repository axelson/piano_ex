defmodule PianoUi.Assets do
  @asset_path Path.join([__DIR__, "..", "..", "assets"]) |> Path.expand()
  paths = Path.wildcard("#{@asset_path}/*")
  paths_hash = :erlang.md5(paths)

  for path <- paths do
    @external_resource path
  end

  use Scenic.Assets.Static,
    otp_app: :piano_ui,
    sources: [
      "assets",
      {:pomodoro, PomodoroUi.Assets.asset_path()},
      {:scenic, "deps/scenic/assets"}
    ],
    alias: [
      roboto: {:scenic, "fonts/roboto.ttf"}
    ]

  def asset_path, do: Path.join([__DIR__, "..", "..", "assets"]) |> Path.expand()

  def __mix_recompile__? do
    Path.wildcard("#{asset_path()}/*") |> :erlang.md5() != unquote(paths_hash)
  end
end
