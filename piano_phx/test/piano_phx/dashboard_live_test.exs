defmodule PianoPhx.DashboardLiveTest do
  use PianoPhx.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders no song playing when disconnected", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "No song playing"
  end
end
