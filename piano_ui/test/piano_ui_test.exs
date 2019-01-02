defmodule PianoUiTest do
  use ExUnit.Case
  IO.puts "pianoui test loading"
  doctest PianoUi

  test "greets the world" do
    assert PianoUi.hello() == :world
  end
end
