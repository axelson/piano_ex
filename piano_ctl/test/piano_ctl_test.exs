defmodule PianoCtlTest do
  use ExUnit.Case
  doctest PianoCtl

  test "greets the world" do
    assert PianoCtl.hello() == :world
  end
end
