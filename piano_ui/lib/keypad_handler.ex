defmodule PianoUi.KeypadHandler do
  use GenServer
  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    InputEvent.enumerate()
    |> Enum.filter(fn {_dev, %{name: name}} ->
      String.starts_with?(name, "MOSART Semi. 2.4G Keyboard Mouse")
    end)
    # We grab the input because we don't want scenic to see the input as well
    |> Enum.each(fn {dev, _} -> InputEvent.start_link(path: dev, grab: true) end)

    {:ok, []}
  end

  @impl GenServer
  # handle keydown
  def handle_info({:input_event, _dev, [_info, {:ev_key, key, 1}]}, scene) do
    case key do
      :key_kp1 ->
        PianoUi.remote_cmd(:stop)

      :key_kp2 ->
        PianoUi.remote_cmd(:play)

      :key_kp3 ->
        PianoUi.remote_cmd(:next)

      :key_kp4 ->
        Phoenix.PubSub.broadcast(:piano_ui_pubsub, "dashboard", :finish_meeting)
        PianoUi.finish_meeting()

      :key_kp5 ->
        Phoenix.PubSub.broadcast(:piano_ui_pubsub, "dashboard", :start_meeting)
        PianoUi.start_meeting()

      :key_kp6 ->
        Pomodoro.PomodoroTimer.next()
    end

    {:noreply, scene}
  end

  # Ignore keyup
  def handle_info({:input_event, _dev, [_info, {:ev_key, _key, 0}]}, scene) do
    {:noreply, scene}
  end

  def handle_info(msg, state) do
    Logger.warn("Unhandled msg: #{inspect(msg)}")
    {:noreply, state}
  end
end
