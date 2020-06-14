defmodule PianoUi.MixProject do
  use Mix.Project

  def project do
    [
      app: :piano_ui,
      version: "0.1.0",
      elixir: "~> 1.7",
      compilers: [:boundary] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {PianoUiApplication, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:boundary, "~> 0.4.0", runtime: false},
      {:libcluster, "~> 3.2.1"},
      {:launcher, github: "axelson/scenic_launcher"},
      {:exsync, github: "falood/exsync", only: :dev, override: true},
      {:mojito, "~> 0.6.4"},
      {:piano_ctl, path: "../piano_ctl", runtime: false},
      {:scenic, "~> 0.10.0"},
      {:scenic_driver_glfw, "~> 0.10", only: :dev},
      {:scenic_live_reload, "~> 0.2", only: :dev},
      {:dialyxir, "1.0.0", only: :dev, runtime: false}
    ]
  end
end
