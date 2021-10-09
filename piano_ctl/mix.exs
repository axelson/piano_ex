defmodule PianoCtl.MixProject do
  use Mix.Project

  def project do
    [
      app: :piano_ctl,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:boundary] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {PianoCtlApplication, []},
      extra_applications: [:logger, :eex]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:beam_notify, "~> 0.2.1"},
      {:boundary, "~> 0.8", runtime: false},
      {:libcluster, "~> 3.3.0"},
      {:exsync, github: "falood/exsync", only: :dev},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:pid_file, "~> 0.1.1"},
      {:typed_struct, "~> 0.2.0"}
    ]
  end
end
