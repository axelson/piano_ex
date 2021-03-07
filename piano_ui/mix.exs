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
      {:boundary, "~> 0.8.0", runtime: false},
      {:libcluster, "~> 3.2.1"},
      {:launcher, github: "axelson/scenic_launcher"},
      {:finch, "~> 0.5"},
      {:pomodoro, github: "axelson/pomodoro"},
      # {:pomodoro, path: "~/dev/pomodoro"},
      {:piano_ctl, path: "../piano_ctl", runtime: false},
      # {:govee_semaphore, path: "~/dev/govee_semaphore"},
      {:govee_semaphore, github: "axelson/govee_semaphore"},
      {:scenic, "~> 0.10.0"},
      {:scenic_driver_glfw, "~> 0.10", only: :dev},
      {:scenic_live_reload, "~> 0.2", only: :dev},
      # {:exsync, path: "~/dev/forks/exsync", only: :dev, override: true},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:exqlite, github: "warmwaffles/exqlite", branch: "main"}
    ]
  end
end
