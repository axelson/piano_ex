defmodule PianoUi.SemaphoreDisplay do
  use Scenic.Component

  require Logger

  alias Scenic.Graph
  alias Scenic.Primitives

  @button_font_size 30

  defmodule State do
    defstruct [:graph]
  end

  @impl Scenic.Component
  def validate(data), do: {:ok, data}

  @impl Scenic.Scene
  def init(scene, opts, _scenic_opts) do
    {base_x, base_y} = Keyword.get(opts, :t)

    start_meeting_btn_t = {base_x, base_y}
    finish_meeting_btn_t = {base_x + 135, base_y}
    clear_meeting_btn_t = {base_x, base_y + 80}

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
      |> Scenic.Components.button("Begin",
        id: :btn_start_meeting,
        t: start_meeting_btn_t,
        button_font_size: @button_font_size
      )
      |> Scenic.Components.button("End",
        id: :btn_finish_meeting,
        t: finish_meeting_btn_t,
        button_font_size: @button_font_size
      )
      |> Scenic.Components.button("Clear",
        id: :btn_clear_meeting,
        t: clear_meeting_btn_t,
        button_font_size: @button_font_size
      )

    state = %State{graph: graph}

    scene =
      scene
      |> assign(:state, state)
      |> push_graph(graph)

    {:ok, scene}
  end

  @impl Scenic.Scene
  def handle_event({:click, :btn_start_meeting}, _from, scene) do
    GoveeSemaphore.start_meeting()
    {:noreply, scene}
  end

  def handle_event({:click, :btn_finish_meeting}, _from, scene) do
    GoveeSemaphore.finish_meeting()
    {:noreply, scene}
  end

  def handle_event({:click, :btn_clear_meeting}, _from, scene) do
    GoveeSemaphore.clear_note()
    {:noreply, scene}
  end

  @impl GenServer
  def handle_info({:govee_semaphore, :submit_note, note}, scene) do
    state = scene.assigns.state
    %State{graph: graph} = state

    note = note || ""
    graph = Graph.modify(graph, :semaphore_note, &Primitives.text(&1, note))

    state = %State{state | graph: graph}

    scene =
      scene
      |> assign(:state, state)
      |> push_graph(graph)

    {:noreply, scene}
  end
end
