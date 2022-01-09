import Config

if System.get_env("UI_NODE") do
  config :piano_ctl, libcluster_hosts: [System.get_env("UI_NODE") |> String.to_atom()]
end
