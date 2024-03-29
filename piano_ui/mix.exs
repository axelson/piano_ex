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
      {:data_tracer, path: "~/dev/data_tracer"},
      {:jax_utils, github: "axelson/jax_utils"},
      {:libcluster, "~> 3.3.0"},
      dep(:icalendar, :github),
      {:finch, "~> 0.10"},
      {:piano_ctl, path: "../piano_ctl", runtime: false},
      # {:govee_semaphore, path: "~/dev/govee_semaphore"},
      {:govee_phx, github: "axelson/govee_phx"},
      {:govee_semaphore, github: "axelson/govee_semaphore"},
      {:font_metrics, "~> 0.5.0"},
      # {:scenic_widget_contrib, github: "scenic-contrib/scenic-widget-contrib"},
      # {:scenic_widget_contrib, github: "axelson/scenic-widget-contrib", branch: "add_wrap_and_shorten_text"},
      {:scenic_widget_contrib, github: "axelson/scenic-widget-contrib", branch: "jax"},
      # {:scenic_widget_contrib, path: "~/dev/forks/scenic-widget-contrib"},
      {:phoenix_pubsub, "~> 2.0"},
      dep(:launcher, :github),
      dep(:pomodoro, :github),
      dep(:ring_logger, :github),
      dep(:scenic, :hex),
      {:scenic_sensor, "~> 0.7.0"},
      dep(:scenic_driver_local, :hex),
      dep(:scenic_live_reload, :hex),
      # {:exsync, github: "falood/exsync", override: true},
      {:exsync, path: "~/dev/forks/exsync", override: true, only: [:dev, :test]},
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

  defp dep(:ring_logger, :path),
    do: {:ring_logger, path: "~/dev/forks/ring_logger", override: true}

  defp dep(:icalendar, :hex), do: {:icalendar, "~> 1.1"}
  defp dep(:icalendar, :github), do: {:icalendar, github: "axelson/icalendar", branch: "my-fork"}
  defp dep(:icalendar, :path), do: {:icalendar, path: "~/dev/forks/icalendar"}

  defp dep(:scenic, :hex), do: {:scenic, "~> 0.11"}

  # defp dep(:scenic, :github),
  #   do: {:scenic, github: "boydm/scenic", override: true}
  defp dep(:scenic, :github),
    do: {:scenic, github: "boydm/scenic", override: true}

  defp dep(:scenic, :path), do: {:scenic, path: "../forks/scenic", override: true}

  defp dep(:scenic_driver_local, :hex), do: {:scenic_driver_local, "~> 0.11"}

  defp dep(:scenic_driver_local, :github),
    do:
      {:scenic_driver_local,
       github: "ScenicFramework/scenic_driver_local", only: :dev, override: true}

  defp dep(:scenic_driver_glfw, :path),
    do: {:scenic_driver_glfw, path: "../forks/scenic_driver_glfw", only: :dev, override: true}

  defp dep(:scenic_live_reload, :hex), do: {:scenic_live_reload, "~> 0.3.0", only: :dev}

  defp dep(:scenic_live_reload, :path),
    do: {:scenic_live_reload, path: "~/dev/scenic_live_reload", only: :dev}
end
