defmodule PianoPhx.PageController do
  use PianoPhx, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
