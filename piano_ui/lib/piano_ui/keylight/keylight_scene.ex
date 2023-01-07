defmodule PianoUi.KeylightScene do
  use Scenic.Scene
  require Logger
  alias Scenic.Graph
  alias Scenic.Primitives
  alias ScenicContrib.Utils.GraphState
  alias ScenicWidgets.GraphTools

  defmodule State do
    defstruct [:graph, :brightness, :temperature, :previous_scene]
  end

  @impl Scenic.Scene
  def init(scene, opts, _scenic_opts) do
    Logger.info("keylight scene startup!")
    Phoenix.PubSub.subscribe(:piano_ui_pubsub, "keylight")
    previous_scene = Keyword.get(opts, :previous_scene)

    keylight_status =
      with mod when not is_nil(mod) <- Application.get_env(:piano_ui, :keylight_module) do
        mod.status()
      end

    initial_warmth =
      case keylight_status do
        {:ok, %{temperature: temperature}} -> temperature
        {:error, _} -> 200
        nil -> 200
      end

    initial_brightness =
      case keylight_status do
        {:ok, %{brightness: brightness}} -> brightness
        {:error, _} -> 50
        nil -> 50
      end

    on =
      case keylight_status do
        {:ok, %{on: on}} -> on == 1
        {:error, _} -> false
        nil -> false
      end

    on_icon =
      case on do
        false -> {:piano_ui, "images/mtg_on_rest.png"}
        true -> {:piano_ui, "images/mtg_on_none.png"}
      end

    off_icon =
      case on do
        true -> {:piano_ui, "images/mtg_off_rest.png"}
        false -> {:piano_ui, "images/mtg_off_none.png"}
      end

    Logger.info("initial_warmth: #{inspect(initial_warmth, pretty: true)}")
    Logger.info("initial_brightness: #{inspect(initial_brightness, pretty: true)}")

    graph =
      Graph.build()
      |> ScenicContrib.IconComponent.add_to_graph(
        [
          icon: on_icon,
          on_press_icon: {:piano_ui, "images/mtg_on_select.png"},
          width: 53,
          height: 44,
          parent_pid: self(),
          on_click: fn self -> send(self, :turn_on) end
        ],
        scale: 1.25,
        id: :btn_turn_on,
        t: {15, 15}
      )
      |> ScenicContrib.IconComponent.add_to_graph(
        [
          icon: off_icon,
          on_press_icon: {:piano_ui, "images/mtg_off_select.png"},
          width: 53,
          height: 44,
          parent_pid: self(),
          on_click: fn self -> send(self, :turn_off) end
        ],
        scale: 1.25,
        id: :btn_turn_off,
        t: {115, 15}
      )
      |> Scenic.Components.button("Back", id: :btn_back, t: {15, 325})
      |> Scenic.Components.button("Reset", id: :btn_reset, t: {225, 325})
      |> Primitives.text("connected: unknown",
        id: :text_connected,
        t: {15, 310},
        font_size: 15,
        fill: :white
      )
      # Temperature sligder
      |> Primitives.text("Warmth", t: {15, 110}, font_size: 25, fill: :white)
      |> Scenic.Components.slider({{145, 344}, initial_warmth}, id: :warmth_slider, t: {15, 120})
      |> Primitives.text("cool", t: {15, 155}, font_size: 18, fill: :white)
      |> Primitives.text("warm", t: {315, 155}, font_size: 18, fill: :white, text_align: :right)
      # Brightness slider
      |> Primitives.text("Brightness", t: {15, 210}, font_size: 25, fill: :white)
      |> Scenic.Components.slider({{0, 100}, initial_brightness},
        id: :brightness_slider,
        t: {15, 220}
      )
      |> Primitives.text("low", t: {15, 255}, font_size: 18, fill: :white)
      |> Primitives.text("high", t: {315, 255}, font_size: 18, fill: :white, text_align: :right)
      # Needs to be last
      |> Launcher.HiddenHomeButton.add_to_graph([])

    initial_state = %State{
      graph: graph,
      temperature: initial_warmth,
      brightness: initial_brightness,
      previous_scene: previous_scene
    }

    scene =
      scene
      |> assign(state: initial_state)
      |> push_graph(graph)

    {:ok, scene}
  end

  @impl Scenic.Scene
  def handle_event({:value_changed, :warmth_slider, value}, _, scene) do
    with mod when not is_nil(mod) <- Application.get_env(:piano_ui, :keylight_module) do
      mod.set(temperature: value)
    end

    scene = GraphState.update_state(scene, fn state -> %State{state | temperature: value} end)

    {:noreply, scene}
  end

  def handle_event({:value_changed, :brightness_slider, value}, _, scene) do
    with mod when not is_nil(mod) <- Application.get_env(:piano_ui, :keylight_module) do
      mod.set(brightness: value)
    end

    scene = GraphState.update_state(scene, fn state -> %State{state | brightness: value} end)

    {:noreply, scene}
  end

  def handle_event({:click, :btn_back}, _, scene) do
    case scene.assigns.state.previous_scene do
      nil -> Launcher.switch_to_launcher(scene.viewport)
      {previous_scene, args} -> Scenic.ViewPort.set_root(scene.viewport, previous_scene, args)
    end

    {:noreply, scene}
  end

  def handle_event({:click, :btn_reset}, _, scene) do
    with mod when not is_nil(mod) <- Application.get_env(:piano_ui, :keylight_module) do
      mod.reset()
    end

    {:noreply, scene}
  end

  def handle_event(event, _, scene) do
    Logger.info("Keylight Scene unhandled event: #{inspect(event, pretty: true)}")
    {:noreply, scene}
  end

  @impl GenServer
  def handle_info(:turn_off, scene) do
    Logger.info("turn off!")

    with mod when not is_nil(mod) <- Application.get_env(:piano_ui, :keylight_module) do
      mod.off()
    end

    scene =
      GraphState.update_graph(scene, fn graph ->
        graph
        |> GraphTools.upsert(:btn_turn_off, fn g ->
          ScenicContrib.IconComponent.upsert(
            g,
            %{icon: {:piano_ui, "images/mtg_off_none.png"}},
            []
          )
        end)
        |> GraphTools.upsert(:btn_turn_on, fn g ->
          ScenicContrib.IconComponent.upsert(
            g,
            %{icon: {:piano_ui, "images/mtg_on_rest.png"}},
            []
          )
        end)
      end)

    {:noreply, scene}
  end

  def handle_info(:turn_on, scene) do
    Logger.info("turn on!")

    with mod when not is_nil(mod) <- Application.get_env(:piano_ui, :keylight_module) do
      %State{temperature: temperature, brightness: brightness} = scene.assigns.state
      mod.set(on: 1, temperature: temperature, brightness: brightness)
    end

    scene =
      GraphState.update_graph(scene, fn graph ->
        graph
        |> GraphTools.upsert(:btn_turn_off, fn g ->
          ScenicContrib.IconComponent.upsert(
            g,
            %{icon: {:piano_ui, "images/mtg_off_rest.png"}},
            []
          )
        end)
        |> GraphTools.upsert(:btn_turn_on, fn g ->
          ScenicContrib.IconComponent.upsert(
            g,
            %{icon: {:piano_ui, "images/mtg_on_none.png"}},
            []
          )
        end)
      end)

    {:noreply, scene}
  end

  def handle_info({:connected?, connected?}, scene) do
    Logger.info("KeylightScene got connected: #{inspect(connected?)}")

    scene =
      GraphState.update_graph(scene, fn graph ->
        graph
        |> GraphTools.upsert(:text_connected, fn g ->
          Primitives.text(g, "connected: #{connected?}",
            id: :text_connected,
            t: {15, 310},
            font_size: 15,
            fill: :white
          )
        end)
      end)

    {:noreply, scene}
  end

  def handle_info(msg, scene) do
    Logger.debug("#{__MODULE__} ignoring unrecognized message: #{inspect(msg)}")
    {:noreply, scene}
  end
end
