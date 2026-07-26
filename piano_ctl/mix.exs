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
      aliases: aliases(),
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

  def cli do
    [
      preferred_envs: [precommit: :test, check: :test]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:beam_notify, "~> 0.2 or ~> 1.0"},
      {:boundary, "~> 0.9", runtime: false},
      {:libcluster, "~> 3.3.0"},
      {:exsync, github: "falood/exsync", only: :dev},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:pid_file, "~> 0.2.0"},
      {:typed_struct, "~> 0.3.0"},
      {:phoenix_pubsub, "~> 2.0"}
    ]
  end

  defp aliases do
    [
      precommit: [
        "compile --warnings-as-errors",
        "deps.unlock --unused",
        "format",
        "test"
      ],
      check: [
        "compile --warnings-as-errors",
        "deps.unlock --unused",
        "format",
        "test",
        "dialyzer"
      ]
    ]
  end
end
