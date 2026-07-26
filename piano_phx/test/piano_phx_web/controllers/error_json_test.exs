defmodule PianoPhxWeb.ErrorJSONTest do
  use PianoPhxWeb.ConnCase, async: true

  test "renders 404" do
    assert PianoPhxWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert PianoPhxWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
