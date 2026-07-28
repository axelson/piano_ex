import Config

config :piano_ctl, libcluster_hosts: []
config :piano_ctl, pubsub: PianoCtl.PubSub
config :piano_ctl, song_topic: "piano:now_playing"
config :pid_file, file: "#{System.user_home!()}/.config/pianobar/piano_ctl_pid"

import_config "#{Mix.env()}.exs"
