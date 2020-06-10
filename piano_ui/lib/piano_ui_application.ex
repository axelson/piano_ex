defmodule PianoUiApplication do
  use Application

  use Boundary, deps: [PianoUi]

  def start(_, _) do
    import Supervisor.Spec, warn: false

    topologies = [
      example: [
        strategy: Cluster.Strategy.Epmd,
        config: [hosts: [:ctl@localhost]]
      ]
    ]

    viewport_config = Application.get_env(:piano_ui, :viewport)

    children = [
      {Cluster.Supervisor, [topologies, [name: PianoUi.ClusterSupervisor]]},
      {DynamicSupervisor, name: PianoUi.MainSupervisor, strategy: :one_for_one},
      {ScenicLiveReload, viewports: [viewport_config]},
      supervisor(Scenic, viewports: [viewport_config])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
