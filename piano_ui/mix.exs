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
      {:boundary, "~> 0.9.0", runtime: false},
      {:jax_utils, path: "~/dev/jax_utils"},
      {:libcluster, "~> 3.3.0"},
      # {:icalendar, "~> 1.1"},
      {:icalendar, path: "~/dev/forks/icalendar"},
      {:finch, "~> 0.10"},
      {:piano_ctl, path: "../piano_ctl", runtime: false},
      # {:govee_semaphore, path: "~/dev/govee_semaphore"},
      {:govee_semaphore, github: "axelson/govee_semaphore"},
      {:font_metrics, "~> 0.5.0"},
      dep(:launcher, :github),
      dep(:pomodoro, :github),
      dep(:ring_logger, :path),
      dep(:scenic, :github),
      {:scenic_sensor, "~> 0.7.0"},
      dep(:scenic_driver_local, :github),
      dep(:scenic_live_reload, :path),
      {:exsync, github: "falood/exsync", override: true},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.4 or ~> 1.0"},
      {:ecto_sqlite3, "~> 0.7"}
    ]
  end

  defp dep(:launcher, :github), do: {:launcher, github: "axelson/scenic_launcher"}
  defp dep(:launcher, :path), do: {:launcher, path: "~/dev/launcher", override: true}

  defp dep(:pomodoro, :github), do: {:pomodoro, github: "axelson/pomodoro"}
  defp dep(:pomodoro, :path), do: {:pomodoro, path: "~/dev/pomodoro"}

  defp dep(:ring_logger, :github), do: {:ring_logger, github: "axelson/ring_logger"}
  defp dep(:ring_logger, :path), do: {:ring_logger, path: "~/dev/forks/ring_logger", override: true}

  defp dep(:scenic, :hex), do: {:scenic, "~> 0.10"}

  # defp dep(:scenic, :github),
  #   do: {:scenic, github: "boydm/scenic", override: true}
  defp dep(:scenic, :github),
    do: {:scenic, github: "axelson/scenic", branch: "update-nimble-options-0.4", override: true}

  defp dep(:scenic, :path), do: {:scenic, path: "../forks/scenic", override: true}

  defp dep(:scenic_driver_local, :hex), do: {:scenic_driver_local, "~> 0.10", only: :dev}

  defp dep(:scenic_driver_local, :github),
    do: {:scenic_driver_local, github: "ScenicFramework/scenic_driver_local", only: :dev, override: true}

  defp dep(:scenic_driver_glfw, :path),
    do: {:scenic_driver_glfw, path: "../forks/scenic_driver_glfw", only: :dev, override: true}

  defp dep(:scenic_live_reload, :hex), do: {:scenic_live_reload, "~> 0.2.0", only: :dev}

  defp dep(:scenic_live_reload, :path),
    do: {:scenic_live_reload, path: "~/dev/scenic_live_reload", only: :dev}
end
