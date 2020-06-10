use Mix.Config

config :piano_ctl, libcluster_hosts: []
config :piano_ctl, ui_node: :ui@localhost

import_config "#{Mix.env()}.exs"
