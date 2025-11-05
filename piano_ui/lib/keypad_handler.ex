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
    fully_node = Application.get_env(:piano_ui, :fully_node)

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

        Task.start(fn ->
          :rpc.call(fully_node, Fully, :move_to_position, [:pos1])
        end)

      :key_kp5 ->
        Phoenix.PubSub.broadcast(:piano_ui_pubsub, "dashboard", :start_meeting)

        Task.start(fn ->
          :rpc.call(fully_node, Fully, :move_to_position, [:pos3])
        end)

        PianoUi.start_meeting()

      :key_kp6 ->
        Pomodoro.PomodoroTimer.next()

      :key_kpdot ->
        Pomodoro.PomodoroTimer.rest()

      :key_kp7 ->
        GoveePhx.all_off()

      :key_kp8 ->
        GoveePhx.party_mode()

      :key_kpminus ->
        Logger.info("kp minus pressed! Switching monitor to desktop")
        PianoUi.monitor_switch_to_desktop()

      :key_kp9 ->
        Logger.info("kp9 pressed! Switch monitor to dock")
        PianoUi.monitor_switch_to_dock()

      :key_kpasterisk ->
        Logger.info("kp* pressed! Turn off gaming desktop monitor")
        PianoUi.monitor_gaming_desktop_turn_off()

      :key_backspace ->
        Logger.info("kp_back pressed! Turn on gaming desktop monitor")
        PianoUi.monitor_gaming_desktop_turn_on()

      :key_tab ->
        Logger.info("key_tab pressed! Lowering desk")

        Task.start(fn ->
          :rpc.call(fully_node, Fully, :move_to_position, [:pos1])
        end)

      :key_equal ->
        Logger.info("key_equal pressed! Raising desk")

        Task.start(fn ->
          :rpc.call(fully_node, Fully, :move_to_position, [:pos3])
        end)

      :key_esc ->
        Phoenix.PubSub.broadcast(:piano_ui_pubsub, "dashboard", :sleep_all)
        # Launcher.LauncherConfig.sleep_all_module().sleep_all()
        # apply(Fw.SleepAll, :sleep_all, [])
    end

    {:noreply, scene}
  end

  # Ignore keyup
  def handle_info({:input_event, _dev, [_info, {:ev_key, _key, 0}]}, scene) do
    {:noreply, scene}
  end

  def handle_info(msg, state) do
    Logger.warning("Unhandled msg: #{inspect(msg)}")
    {:noreply, state}
  end
end
