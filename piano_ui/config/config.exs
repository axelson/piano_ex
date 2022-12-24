import Config

config :piano_ui, ecto_repos: [PianoUi.Repo, Pomodoro.Repo]

# Set this to respond to meetings starting or finishing
# the module should implement the PianoUi.MeetingBehaviour
config :piano_ui, meeting_module: nil
