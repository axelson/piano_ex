defmodule PianoCtl.PianoParserTest do
  use ExUnit.Case

  alias PianoCtl.PianoParser

  test "parse an event" do
    assert {:ok, :in_progress, state} = PianoParser.parse("songstart\n")
    assert state == {:event_name, "songstart"}
    contents = PianoCtlTest.TestHelpers.load_fixture(:song_start_body)

    assert {:ok, :event, %PianoParser.Event{} = event, :empty} =
             PianoParser.parse(state, contents)

    assert event.album ==
             "Weiner Philharmoniker, New Year's Day Concert In Vienna, 1979 [Australia]"

    assert event.artist == "Johann Strauss II"

    assert event.cover_art ==
             "http://cont-3.p-cdn.us/images/public/rovi/albumart/0/2/9/8/028946848920_500W_500H.jpg"

    assert event.detail_url ==
             "http://www.pandora.com/weiner-philharmoniker/new-years-day-concert-in-vienna-1979-australia/der-schonen-blauen-donau/TRhg7mxf5Z6wPzc?dc=232&ad=0:33:1:96822::0:0:0:0:744:099:HI:15003:2:0:0:0:1100:0"

    assert event.event_name == "songstart"
    assert event.p_ret == "1"
    assert event.p_ret_str == "Everything is fine :)"
    assert event.rating == "0"
    assert event.song_duration == "563"
    assert event.song_played == "0"
    assert event.song_station_name == ""
    assert event.station_count == "51"
    assert event.station_name == "Christmas Radio"

    assert event.title ==
             "An Der Schönen, Blauen Donau (On The Beautiful, Blue Danube), Waltz For Orchestra (With Chorus Ad Lib), Op. 314 (Rv 314)"

    assert event.w_ret == "0"
    assert event.w_ret_str == "No error"

    assert length(event.stations) == 51
  end

  test "parse songstart full" do
    contents = PianoCtlTest.TestHelpers.load_fixture(:song_start_full)

    assert {:ok, :event, %PianoParser.Event{} = event, :empty} = PianoParser.parse(contents)

    assert event.album ==
             "Weiner Philharmoniker, New Year's Day Concert In Vienna, 1979 [Australia]"

    assert event.artist == "Johann Strauss II"

    assert event.cover_art ==
             "http://cont-3.p-cdn.us/images/public/rovi/albumart/0/2/9/8/028946848920_500W_500H.jpg"

    assert event.detail_url ==
             "http://www.pandora.com/weiner-philharmoniker/new-years-day-concert-in-vienna-1979-australia/der-schonen-blauen-donau/TRhg7mxf5Z6wPzc?dc=232&ad=0:33:1:96822::0:0:0:0:744:099:HI:15003:2:0:0:0:1100:0"

    assert event.event_name == "songstart"
    assert event.p_ret == "1"
    assert event.p_ret_str == "Everything is fine :)"
    assert event.rating == "0"
    assert event.song_duration == "563"
    assert event.song_played == "0"
    assert event.song_station_name == ""
    assert event.station_count == "51"
    assert event.station_name == "Christmas Radio"

    assert event.title ==
             "An Der Schönen, Blauen Donau (On The Beautiful, Blue Danube), Waltz For Orchestra (With Chorus Ad Lib), Op. 314 (Rv 314)"

    assert event.w_ret == "0"
    assert event.w_ret_str == "No error"

    assert length(event.stations) == 51
  end

  # describe "parse/1" do
  #   test "parse" do
  #     IO.puts "go"
  #     contents = File.read!("#{__DIR__}/../example_input/songstart-03:58:04:1545101884.txt")
  #     IO.inspect(contents, label: "contents")
  #   end
  # end
end
