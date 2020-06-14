use Mix.Config

config :piano_ctl, libcluster_hosts: []
config :piano_ctl, ui_node: :ui@localhost
config :pid_file, file: "#{System.user_home!()}/.config/pianobar/piano_ctl_pid"

import_config "#{Mix.env()}.exs"
