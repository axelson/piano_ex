defmodule PianoUiApplication do
  use Application

  use Boundary, deps: [PianoUi]

  def start(_, _) do
    import Supervisor.Spec, warn: false

    topologies = [
      example: [
        strategy: Application.fetch_env!(:piano_ui, :libcluster_strategy),
        config: [hosts: Application.fetch_env!(:piano_ui, :libcluster_hosts)]
      ]
    ]

    children =
      [
        {Finch, name: :piano_ui_finch},
        {Cluster.Supervisor, [topologies, [name: PianoUi.ClusterSupervisor]]},
        {DynamicSupervisor, name: PianoUi.MainSupervisor, strategy: :one_for_one},
        {Scenic.Sensor, nil},
        PianoUi.CalendarCache,
        PianoUi.Repo,
        PianoUi.Telemetry,
        maybe_start_scenic()
      ]
      |> List.flatten()

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  if Mix.env() == :test do
    defp maybe_start_scenic, do: []
  else
    defp maybe_start_scenic do
      main_viewport_config = Application.get_env(:piano_ui, :viewport)

      if main_viewport_config do
        [
          {Scenic, [main_viewport_config]},
          {ScenicLiveReload, viewports: [main_viewport_config]}
        ]
        |> List.flatten()
      else
        []
      end
    end
  end
end
