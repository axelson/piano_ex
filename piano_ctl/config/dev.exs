use Mix.Config

config :piano_ctl, libcluster_hosts: [System.get_env("UI_NODE") |> String.to_atom()]
