defmodule PianoCtl.Application do
  use Application

  def start(_, _) do
    import Supervisor.Spec, warn: false

    topologies = [
      example: [
        strategy: Cluster.Strategy.Epmd,
        config: [hosts: [:"ui@localhost"]],
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: PianoCtl.ClusterSupervisor]]},
      PianoCtl.PianoInputReader
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
