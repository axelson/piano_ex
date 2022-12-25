defmodule PianoUi.SemaphoreDisplay do
  use Scenic.Component

  require Logger

  alias Scenic.Graph
  alias Scenic.Primitives

  defmodule State do
    defstruct [:graph]
  end

  @impl Scenic.Component
  def validate(data), do: {:ok, data}

  @impl Scenic.Scene
  def init(scene, opts, _scenic_opts) do
    {base_x, base_y} = Keyword.get(opts, :t)

    text_t = {base_x, base_y + 70}

    :ok = GoveeSemaphore.subscribe()
    note = GoveeSemaphore.get_note()

    keylight_status =
      with mod when not is_nil(mod) <- Application.get_env(:piano_ui, :keylight_module) do
        mod.status()
      end

    on =
      case keylight_status do
        {:ok, %{on: on}} -> on == 1
        {:error, _} -> false
        nil -> false
      end

    graph =
      Graph.build()
      |> Primitives.text(note || "",
        id: :semaphore_note,
        t: text_t,
        fill: :white,
        text_align: :left,
        font_size: 30
      )
      |> ScenicContrib.IconComponent.add_to_graph(
        [
          icon: meeting_btn_on_fill(on),
          on_press_icon: {:piano_ui, "images/mtg_on_select.png"},
          width: 53,
          height: 44,
          parent_pid: self(),
          on_click: &start_meeting/1
        ],
        id: :btn_start_meeting,
        t: {249, 385}
      )
      |> ScenicContrib.IconComponent.add_to_graph(
        [
          icon: meeting_btn_off_fill(on),
          on_press_icon: {:piano_ui, "images/mtg_off_select.png"},
          width: 53,
          height: 44,
          parent_pid: self(),
          on_click: &finish_meeting/1
        ],
        id: :btn_finish_meeting,
        t: {309, 385}
      )
      |> ScenicContrib.IconComponent.add_to_graph(
        [
          icon: meeting_icon_fill(on),
          width: 67,
          height: 90,
          parent_pid: self(),
          on_click: fn self -> send(self, :switch_to_keylight) end
        ],
        id: :btn_meeting_icon,
        t: {272, 285}
      )

    state = %State{graph: graph}

    scene =
      scene
      |> assign(state: state)
      |> push_graph(graph)

    {:ok, scene}
  end

  @impl GenServer
  def handle_info(:switch_to_keylight, scene) do
    Logger.info("Switch to keylight!!!")

    Scenic.ViewPort.set_root(scene.viewport, PianoUi.KeylightScene,
      # HACK: It's weird for SemaphoreDisplay to know how to start the Dashboard
      previous_scene: {PianoUi.Scene.Dashboard, [pomodoro_timer_pid: Pomodoro.PomodoroTimer]}
    )

    {:noreply, scene}
  end

  def handle_info({:govee_semaphore, :submit_note, note}, scene) do
    note = note || ""

    scene =
      update_and_render(scene, fn graph ->
        Graph.modify(graph, :semaphore_note, &Primitives.text(&1, note))
      end)

    {:noreply, scene}
  end

  def handle_info(:start_meeting, scene) do
    scene =
      update_and_render(scene, fn graph ->
        # TODO: These two calls (start_meeting and finish_meeting) are _very_ similar
        Graph.modify(graph, :btn_meeting_icon, &render_meeting_icon(&1, true))
        |> ScenicWidgets.GraphTools.upsert(:btn_start_meeting, fn g ->
          g
          |> ScenicContrib.IconComponent.upsert([icon: meeting_btn_on_fill(true)], [])
        end)
        |> ScenicWidgets.GraphTools.upsert(:btn_finish_meeting, fn g ->
          g
          |> ScenicContrib.IconComponent.upsert([icon: meeting_btn_off_fill(true)], [])
        end)
      end)

    {:noreply, scene}
  end

  def handle_info(:finish_meeting, scene) do
    scene =
      update_and_render(scene, fn graph ->
        graph
        |> Graph.modify(:btn_meeting_icon, &render_meeting_icon(&1, false))
        |> ScenicWidgets.GraphTools.upsert(:btn_start_meeting, fn g ->
          g
          |> ScenicContrib.IconComponent.upsert([icon: meeting_btn_on_fill(false)], [])
        end)
        |> ScenicWidgets.GraphTools.upsert(:btn_finish_meeting, fn g ->
          g
          |> ScenicContrib.IconComponent.upsert([icon: meeting_btn_off_fill(false)], [])
        end)
      end)

    {:noreply, scene}
  end

  defp update_and_render(scene, fun) when is_function(fun, 1) do
    state = scene.assigns.state
    graph = fun.(state.graph)
    state = %State{state | graph: graph}

    scene
    |> assign(:state, state)
    |> push_graph(graph)
  end

  defp meeting_icon_fill(false), do: {:piano_ui, "images/mtg_icon_off.png"}
  defp meeting_icon_fill(true), do: {:piano_ui, "images/mtg_icon_on.png"}

  defp meeting_btn_on_fill(false), do: {:piano_ui, "images/mtg_on_rest.png"}
  defp meeting_btn_on_fill(true), do: {:piano_ui, "images/mtg_on_none.png"}

  defp meeting_btn_off_fill(true), do: {:piano_ui, "images/mtg_off_rest.png"}
  defp meeting_btn_off_fill(false), do: {:piano_ui, "images/mtg_off_none.png"}

  defp render_meeting_icon(graph, meeting_in_progress) do
    graph
    |> ScenicContrib.IconComponent.upsert(
      [
        icon: meeting_icon_fill(meeting_in_progress),
        width: 67,
        height: 90,
        parent_pid: self(),
        on_click: fn self -> send(self, :switch_to_keylight) end
      ],
      id: :btn_meeting_icon,
      t: {272, 285}
    )
  end

  defp start_meeting(self) do
    send(self, :start_meeting)

    with mod when not is_nil(mod) <- Application.get_env(:piano_ui, :meeting_module) do
      Logger.info("mod: #{inspect(mod, pretty: true)}")
      mod.start_meeting()
    end
  end

  defp finish_meeting(self) do
    send(self, :finish_meeting)

    with mod when not is_nil(mod) <- Application.get_env(:piano_ui, :meeting_module) do
      mod.finish_meeting()
    end
  end
end
