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
      {:libcluster, "~> 3.3.0"},
      {:finch, "~> 0.5"},
      {:piano_ctl, path: "../piano_ctl", runtime: false},
      # {:govee_semaphore, path: "~/dev/govee_semaphore"},
      {:govee_semaphore, github: "axelson/govee_semaphore"},
      {:font_metrics, "~> 0.5.0"},
      dep(:launcher, :github),
      dep(:pomodoro, :github),
      dep(:scenic, :github),
      dep(:scenic_driver_glfw, :github),
      dep(:scenic_live_reload, :path),
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.4"},
      {:ecto_sqlite3, "~> 0.5.4"}
    ]
  end

  defp dep(:launcher, :github), do: {:launcher, github: "axelson/scenic_launcher"}
  defp dep(:launcher, :path), do: {:launcher, path: "~/dev/launcher", override: true}

  defp dep(:pomodoro, :github), do: {:pomodoro, github: "axelson/pomodoro", sparse: "pomodoro"}
  defp dep(:pomodoro, :path), do: {:pomodoro, path: "~/dev/pomodoro/pomodoro"}

  defp dep(:scenic, :hex), do: {:scenic, "~> 0.10"}

  defp dep(:scenic, :github),
    do: {:scenic, github: "boydm/scenic", branch: "v0.11", override: true}

  defp dep(:scenic, :path), do: {:scenic, path: "../forks/scenic", override: true}

  defp dep(:scenic_driver_glfw, :hex), do: {:scenic_driver_glfw, "~> 0.10", only: :dev}

  defp dep(:scenic_driver_glfw, :github),
    do:
      {:scenic_driver_glfw,
       github: "boydm/scenic_driver_glfw", branch: "v0.11", only: :dev, override: true}

  defp dep(:scenic_driver_glfw, :path),
    do: {:scenic_driver_glfw, path: "../forks/scenic_driver_glfw", only: :dev, override: true}

  defp dep(:scenic_live_reload, :hex), do: {:scenic_live_reload, "~> 0.2.0", only: :dev}

  defp dep(:scenic_live_reload, :path),
    do: {:scenic_live_reload, path: "~/dev/scenic_live_reload", only: :dev}
end
