defmodule PianoUiApplication do
  use Application

  use Boundary, deps: [PianoUi]

  def start(_, _) do
    import Supervisor.Spec, warn: false

    topologies = [
      example: [
        strategy: Cluster.Strategy.Epmd,
        config: [hosts: Application.fetch_env!(:piano_ui, :libcluster_hosts)]
      ]
    ]

    children =
      [
        {Cluster.Supervisor, [topologies, [name: PianoUi.ClusterSupervisor]]},
        {DynamicSupervisor, name: PianoUi.MainSupervisor, strategy: :one_for_one},
        maybe_start_scenic()
      ]
      |> List.flatten()

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp maybe_start_scenic do
    main_viewport_config = Application.get_env(:piano_ui, :viewport)

    if main_viewport_config do
      [
        {Scenic, viewports: [main_viewport_config]},
        {ScenicLiveReload, viewports: [main_viewport_config]}
      ]
    else
      []
    end
  end
end
