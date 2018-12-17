defmodule PianoCtl.PianoInputReader do
  @moduledoc """
  Reads from the input pipe and sends the message on

  Infinitely loop on reading input.pipe
  """
  use GenServer

  @impl true
  def init(_args) do
    schedule_work()
    {:ok, :default}
  end

  @impl true
  def handle_info({:read_pipe}, state) do
    IO.puts "Reading pipe"
    case File.read(input_file()) do
      {:ok, input} ->
        IO.puts "got input: #{input}"
        schedule_work()
        {:noreply, state}
      {:error, msg} ->
        IO.puts "Got error message: #{msg}"
        Process.sleep(1000)
        schedule_work()
        {:noreply, state}
    end
  end

  defp schedule_work do
    Process.send_after(self(), {:read_pipe}, 0)
  end

  defp input_file, do: "../input.pipe"
end
