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
      {BEAMNotify, name: "any name", path: "/tmp/piano_ctl_beam_notify_socket", dispatcher: &PianoCtl.PianoInputReader.notify/2},
      PianoCtl.Initializer,
      PianoCtl.Server,
      PianoCtl.Reconnector,
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
