defmodule PianoCtlTest.TestHelpers do
  @fixtures %{
    song_start_full: "songstart-03:58:04:1545101884.txt",
    song_start_body: "songstart-body.txt",
    raw_song_start: "songstart_raw.txt"
  }

  def load_fixture(fixture) do
    path = Map.fetch!(@fixtures, fixture)
    File.read!("#{__DIR__}/../example_input/#{path}")
  end
end
