defmodule PianoCtl.MixProject do
  use Mix.Project

  def project do
    [
      app: :piano_ctl,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {PianoCtl.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 3.0.3"},
      # {:exsync, github: "axelson/exsync", only: :dev},
      {:exsync, path: "/Users/jason/dev/forks/exsync", only: :dev},
      {:dialyxir, "1.0.0-rc.4", only: :dev, runtime: false}
    ]
  end
end
