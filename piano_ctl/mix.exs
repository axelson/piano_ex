defmodule PianoCtl.MixProject do
  use Mix.Project

  def project do
    [
      app: :piano_ctl,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
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

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 3.0.3"},
      {:exsync, github: "falood/exsync", only: :dev},
      {:dialyxir, "1.0.0-rc.4", only: :dev, runtime: false},
      {:typed_struct, "~> 0.2.0"}
    ]
  end
end
