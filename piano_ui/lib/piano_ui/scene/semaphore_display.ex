defmodule PianoUi.SemaphoreDisplay do
  use Scenic.Component

  require Logger

  alias Scenic.Graph
  alias Scenic.Primitives

  defmodule State do
    defstruct [:graph]
  end

  @impl Scenic.Component
  def verify(data), do: {:ok, data}

  @impl Scenic.Scene
  def init(opts, _scenic_opts) do
    {base_x, base_y} = Keyword.get(opts, :t)

    start_meeting_btn_t = {base_x, base_y}
    finish_meeting_btn_t = {base_x + 85, base_y}
    clear_meeting_btn_t = {base_x + 156, base_y}

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
        button_font_size: 20
      )
      |> Scenic.Components.button("End",
        id: :btn_finish_meeting,
        t: finish_meeting_btn_t,
        button_font_size: 20
      )
      |> Scenic.Components.button("Clear",
        id: :btn_clear_meeting,
        t: clear_meeting_btn_t,
        button_font_size: 20
      )

    state = %State{graph: graph}
    {:ok, state, push: graph}
  end

  @impl Scenic.Scene
  def filter_event({:click, :btn_start_meeting}, _from, state) do
    GoveeSemaphore.start_meeting()
    {:noreply, state}
  end

  def filter_event({:click, :btn_finish_meeting}, _from, state) do
    GoveeSemaphore.finish_meeting()
    {:noreply, state}
  end

  def filter_event({:click, :btn_clear_meeting}, _from, state) do
    GoveeSemaphore.clear_note()
    {:noreply, state}
  end

  @impl Scenic.Scene
  def handle_info({:govee_semaphore, :submit_note, note}, state) do
    %State{graph: graph} = state

    graph = Graph.modify(graph, :semaphore_note, &Primitives.text(&1, note))

    state = %State{state | graph: graph}
    {:noreply, state, push: graph}
  end
end
