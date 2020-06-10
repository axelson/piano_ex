defmodule PianoUi.MixProject do
  use Mix.Project

  def project do
    [
      app: :piano_ui,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {PianoUi.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 3.2.1"},
      {:exsync, github: "falood/exsync", only: :dev},
      {:scenic, "~> 0.9.0"},
      # {:scenic, github: "boydm/scenic", branch: "master", override: true},
      {:scenic_driver_glfw, "~> 0.9"},
      # {:scenic_driver_glfw, github: "boydm/scenic_driver_glfw", branch: "master"}
      {:dialyxir, "1.0.0", only: :dev, runtime: false}
    ]
  end
end
