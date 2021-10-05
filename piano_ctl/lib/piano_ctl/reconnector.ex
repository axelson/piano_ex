defmodule PianoCtl.Reconnector do
  @moduledoc """
  Super hacky way to stay connected
  """
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    schedule_tick()
    {:ok, []}
  end

  def handle_info(:tick, state) do
    Application.fetch_env!(:piano_ctl, :libcluster_hosts)
    |> Enum.each(fn host -> Node.connect(host) end)

    schedule_tick()

    {:noreply, state}
  end

  defp schedule_tick, do: Process.send_after(self(), :tick, 1_000)
end
