defmodule PianoCtl.CommandRunner do
  @moduledoc """
  Execute commands on Pianobar's control pipe
  """

  require Logger

  @commands %{
    :play_pause => "p",
    :next => "n",
    :play => "P",
    :stop => "S",
    :quit => "q"
  }

  def cmd(command) do
    if pianobar_running?() do
      run_command(command)
    end
  end

  defp run_command(command) do
    case Map.get(@commands, command) do
      command_string when not is_nil(command_string) ->
        pipe_path = PianoCtl.Config.control_pipe_path()
        Logger.info("Sending command string #{inspect(command_string)} to #{inspect(pipe_path)}")
        # `File.write/3` would be more straightforward here but we're not using
        # PianoCtl.PipeReader yet so we need to do this instead

        "echo \"#{command_string}\" > #{pipe_path}"
        |> to_charlist()
        |> :os.cmd()
    end
  end

  def pianobar_running? do
    :os.cmd('ps -u $(id -u) -o comm | grep -q "^pianobar$"; echo $?') == '0\n'
  end
end
