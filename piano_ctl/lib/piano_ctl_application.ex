defmodule PianoCtlApplication do
  use Application

  use Boundary, deps: [PianoCtl]

  def start(_, _) do
    topologies = [
      example: [
        strategy: Cluster.Strategy.Epmd,
        config: [hosts: Application.fetch_env!(:piano_ctl, :libcluster_hosts)]
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: PianoCtl.ClusterSupervisor]]},
      PianoCtl.Initializer,
      PianoCtl.Server,
      PianoCtl.Reconnector,
      PianoCtl.PianoInputReader
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
