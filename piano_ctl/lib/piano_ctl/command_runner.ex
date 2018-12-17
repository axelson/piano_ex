defmodule PianoCtl.CommandRunner do
  @moduledoc """
  Execute commands on Pianobar's control pipe
  """

  @commands %{
    :pause => "p",
    :next_song => "n",
    :play => "P",
    :quit => "q"
  }

  def cmd(command) do
    case Map.get(@commands, command) do
      command_string when not is_nil(command_string) ->
        ctl_file_path = "#{PianoCtl.config_folder()}/ctl"
        File.write!(ctl_file_path, command_string)
    end
  end

end
