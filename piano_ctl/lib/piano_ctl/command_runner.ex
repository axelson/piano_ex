defmodule PianoCtl.CommandRunner do
  @moduledoc """
  Execute commands on pianobar.

  Sends command characters via a configurable sender function. When
  `:stdin_sender` is configured (e.g. to PianobarDaemon.send_command),
  commands go through pianobar's stdin Port. Otherwise falls back to
  writing to the control FIFO.
  """

  use GenServer
  require Logger

  @commands %{
    :play_pause => "p",
    :next => "n",
    :play => "P",
    :stop => "S",
    :quit => "q"
  }

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def cmd(command) do
    GenServer.call(__MODULE__, {:cmd, command})
  end

  @impl GenServer
  def init(_opts) do
    {:ok, %{fd: nil}}
  end

  @impl GenServer
  def handle_call({:cmd, command}, _from, state) do
    case Map.get(@commands, command) do
      nil ->
        {:reply, {:error, :unknown_command}, state}

      command_string ->
        Logger.info("Sending command #{inspect(command)} (#{inspect(command_string)})")

        case Application.get_env(:piano_ctl, :stdin_sender) do
          {mod, fun} ->
            apply(mod, fun, [command_string])
            {:reply, :ok, state}

          nil ->
            {result, state} = write_to_fifo(state, command_string)
            {:reply, result, state}
        end
    end
  end

  defp write_to_fifo(state, command_string) do
    case ensure_fd(state) do
      {:ok, state} ->
        case :file.write(state.fd, command_string) do
          :ok ->
            {:ok, state}

          {:error, reason} ->
            Logger.warning("FIFO write failed (#{reason}), reopening")
            {:ok, state} = open_fd(%{state | fd: nil})
            :file.write(state.fd, command_string)
            {:ok, state}
        end

      {:error, reason} ->
        Logger.error("Cannot open control FIFO: #{inspect(reason)}")
        {{:error, reason}, state}
    end
  end

  defp ensure_fd(%{fd: nil} = state), do: open_fd(state)
  defp ensure_fd(state), do: {:ok, state}

  defp open_fd(state) do
    pipe_path = PianoCtl.Config.control_pipe_path()

    case :file.open(pipe_path, [:write, :raw]) do
      {:ok, fd} -> {:ok, %{state | fd: fd}}
      {:error, reason} -> {:error, reason}
    end
  end

  def pianobar_running? do
    :os.cmd(~c"ps | grep pianobar | grep -v grep > /dev/null 2>&1; echo $?") == ~c"0\n"
  end
end
