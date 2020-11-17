defmodule ScenicContrib.IconComponent do
  @moduledoc """
  Responsible for displaying an image, tracking clicks to it, and when clicked
  it displays an alternate image (depressed state)
  """

  use Scenic.Component, has_children: true

  alias Scenic.Graph

  defmodule State do
    defstruct [:icon, :on_press_icon, :on_click, :width, :height, depressed: false]
  end

  @default_width 100
  @default_height 100

  @impl Scenic.Component
  def verify(data), do: {:ok, data}

  @impl Scenic.Scene
  def init(opts, _scenic_opts) do
    icon = Keyword.get(opts, :icon)
    on_press_icon = Keyword.get(opts, :on_press_icon)
    width = Keyword.get(opts, :width, @default_width)
    height = Keyword.get(opts, :height, @default_height)

    icon.load(scope: :global)
    if on_press_icon, do: on_press_icon.load(scope: :global)
    on_click = Keyword.get(opts, :on_click)

    state = %State{
      icon: icon,
      on_press_icon: on_press_icon,
      on_click: on_click,
      width: width,
      height: height
    }

    graph = render(state, false)

    {:ok, state, push: graph}
  end

  @impl Scenic.Scene
  def handle_input({:cursor_button, {_, :press, _, _}}, _context, state) do
    %State{on_click: on_click} = state
    if on_click, do: on_click.()

    graph = render(state, true)

    # I would've preferred to let these events bubble up to the MusicControls
    # component but {:cont, state} here appears to result in an infinite loop

    {:noreply, state, push: graph}
  end

  def handle_input({:cursor_button, {_, :release, _, _}}, _context, state) do
    graph = render(state, false)
    {:noreply, state, push: graph}
  end

  def handle_input(_input, _context, state) do
    {:noreply, state}
  end

  defp render(state, depressed) do
    %State{icon: icon, on_press_icon: on_press_icon, width: width, height: height} = state

    fill =
      if depressed && on_press_icon do
        {:image, on_press_icon.compile_hash()}
      else
        {:image, icon.compile_hash()}
      end

    Graph.build()
    |> Scenic.Primitives.rect(
      {width, height},
      fill: fill
    )
  end
end
