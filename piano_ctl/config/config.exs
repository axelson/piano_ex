use Mix.Config

config :piano_ctl, libcluster_hosts: []

import_config "#{Mix.env()}.exs"
