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
          icon: {:piano_ui, "images/mtg_on_rest.png"},
          on_press_icon: {:piano_ui, "images/mtg_on_select.png"},
          width: 53,
          height: 44,
          on_click: &start_meeting/0
        ],
        id: :btn_start_meeting,
        t: {249, 385}
      )
      |> ScenicContrib.IconComponent.add_to_graph(
        [
          icon: {:piano_ui, "images/mtg_off_rest.png"},
          on_press_icon: {:piano_ui, "images/mtg_off_select.png"},
          width: 53,
          height: 44,
          on_click: &finish_meeting/0
        ],
        id: :btn_finish_meeting,
        t: {309, 385}
      )
      |> Primitives.rect({67, 90},
        fill: {:image, {:piano_ui, "images/mtg_icon_off.png"}},
        id: :meeting_icon,
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
        Graph.modify(graph, :meeting_icon, &render_meeting_icon(&1, true))
      end)

    {:noreply, scene}
  end

  def handle_info(:finish_meeting, scene) do
    scene =
      update_and_render(scene, fn graph ->
        Graph.modify(graph, :meeting_icon, &render_meeting_icon(&1, false))
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

  defp meeting_icon_fill(false), do: {:image, {:piano_ui, "images/mtg_icon_off.png"}}
  defp meeting_icon_fill(true), do: {:image, {:piano_ui, "images/mtg_icon_on.png"}}

  defp render_meeting_icon(graph, meeting_in_progress) do
    graph
    |> Primitives.rect({67, 90},
      fill: meeting_icon_fill(meeting_in_progress),
      id: :meeting_icon,
      t: {272, 285}
    )
  end

  defp start_meeting do
    send(self(), :start_meeting)
    GoveeSemaphore.start_meeting()
  end

  defp finish_meeting do
    send(self(), :finish_meeting)
    GoveeSemaphore.finish_meeting()
  end
end
