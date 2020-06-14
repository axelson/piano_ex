defmodule PianoCtl.Config do
  def input_pipe_path do
    "#{pianobar_config_folder()}/input.pipe"
  end

  def control_pipe_path do
    "#{pianobar_config_folder()}/ctl"
  end

  def event_command_path do
    "#{pianobar_config_folder()}/command.sh"
  end

  def pianobar_config_folder do
    "#{System.user_home!()}/.config/pianobar"
  end

  def ui_node, do: Application.fetch_env!(:piano_ctl, :ui_node)
end
