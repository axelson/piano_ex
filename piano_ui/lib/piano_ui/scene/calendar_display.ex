defmodule PianoUi.Scene.CalendarDisplay do
  @moduledoc """
  Displays the next appointment
  """

  use Scenic.Component
  require Logger
  alias Scenic.Graph

  @font_size 16

  # Note: This will be reduced once I'm more confident that the displayed time
  # until the event is accurate
  @minutes_cutoff 60 * 24 * 365

  @impl Scenic.Component
  def validate(data), do: {:ok, data}

  @impl Scenic.Scene
  def init(scene, _opts, _scenic_opts) do
    Scenic.Sensor.subscribe(:calendar)

    graph =
      Graph.build()
      |> Scenic.Primitives.text("Title",
        id: :calendar_display_text,
        fill: :white,
        text_base: :middle,
        font_size: @font_size,
        t: {0, 20}
      )
      |> Scenic.Primitives.text("X minutes",
        id: :calendar_time_remaining,
        text_base: :middle,
        font_size: @font_size,
        t: {0, 80}
      )

    scene =
      push_graph(scene, graph)
      |> assign(graph: graph)

    {:ok, scene}
  end

  @impl GenServer
  def handle_info({:sensor, :data, {:calendar, %ICalendar.Event{} = event, _timestamp}}, scene) do
    {:ok, {_type, font_metrics}} = Scenic.Assets.Static.meta(:roboto)
    line_width = 190
    num_lines = 3

    title_text = ScenicWidgets.Utils.wrap_and_shorten_text(event.summary, line_width, num_lines, @font_size, font_metrics)

    # Logger.info("Shortened title text: #{inspect(title_text)}")

    minutes_until_start =
      DateTime.diff(event.dtstart, DateTime.utc_now(), :second)
      |> div(60)

    time_until_start = time_until_start(minutes_until_start)
    visible = minutes_until_start <= @minutes_cutoff

    graph =
      scene.assigns.graph
      |> Graph.modify(
        :calendar_display_text,
        &Scenic.Primitives.text(&1, title_text, hidden: !visible)
      )
      |> Graph.modify(
        :calendar_time_remaining,
        &Scenic.Primitives.text(&1, time_until_start, hidden: !visible)
      )

    scene =
      scene
      |> push_graph(graph)
      |> assign(graph: graph)

    {:noreply, scene}
  end

  def handle_info({:sensor, :data, {:calendar, nil, _timestamp}}, scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(
        :calendar_display_text,
        &Scenic.Primitives.text(&1, "", hidden: true)
      )
      |> Graph.modify(
        :calendar_time_remaining,
        &Scenic.Primitives.text(&1, "", hidden: true)
      )

    scene =
      scene
      |> push_graph(graph)
      |> assign(graph: graph)

    {:noreply, scene}
  end

  # ignore register and unregsiter
  def handle_info({:sensor, :registered, _}, scene), do: {:noreply, scene}
  def handle_info({:sensor, :unregistered, _}, scene), do: {:noreply, scene}

  def handle_info(msg, scene) do
    Logger.info("CalendarDisplay unhandled message: #{inspect(msg)}")
    {:noreply, scene}
  end

  defp time_until_start(minutes)
  defp time_until_start(minutes) when minutes < 60, do: "#{minutes} minutes"

  defp time_until_start(minutes) when minutes < 180 do
    :erlang.float_to_binary(minutes / 60, [{:decimals, 1}]) <> " hours"
  end

  defp time_until_start(minutes) when minutes < 60 * 24 do
    to_string(round(minutes / 60)) <> " hours"
  end

  defp time_until_start(minutes) do
    to_string(round(minutes / (60 * 24))) <> " days"
  end
end
