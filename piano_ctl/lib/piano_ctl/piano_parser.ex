defmodule PianoCtl.PianoParser do
  @attributes %{
    "artist" => :artist,
    "title" => :title,
    "album" => :album,
    "coverArt" => :cover_art,
    "stationName" => :station_name,
    "songStationName" => :song_station_name,
    "pRet" => :p_ret,
    "pRetStr" => :p_ret_str,
    "wRet" => :w_ret,
    "wRetStr" => :w_ret_str,
    "songDuration" => :song_duration,
    "songPlayed" => :song_played,
    "rating" => :rating,
    "detailUrl" => :detail_url,
    "stationCount" => :station_count
  }

  @type state :: any()

  defmodule Event do
    use TypedStruct

    typedstruct do
      field :event_name, String.t()
      field :artist, String.t()
      field :title, String.t()
      field :album, String.t()
      field :cover_art, String.t()
      field :station_name, String.t()
      field :song_station_name, String.t()
      field :p_ret, String.t()
      field :p_ret_str, String.t()
      field :w_ret, String.t()
      field :w_ret_str, String.t()
      field :song_duration, String.t()
      field :song_played, String.t()
      field :rating, String.t()
      field :detail_url, String.t()
      field :station_count, String.t()
      field :stations, [any()]
    end
  end

  def parse(state \\ :empty, input)

  def parse(:empty, input) do
    # This is the beginning of parsing so we're receiving a new event
    # [event_name, "", ""] = String.split(input, "\n")

    case String.split(input, "\n") do
      [event_name, ""] ->
        {:ok, :in_progress, {:event_name, event_name}}

      [event_name | lines] ->
        parse({:event_name, event_name}, Enum.join(lines, "\n"))
    end
  end

  def parse({:event_name, event_name}, input) do
    lines = String.split(input, "\n", trim: true)

    map =
      parse_lines(lines)
      |> Map.put(:event_name, event_name)

    {:ok, :event, struct(Event, map), :empty}
  end

  defp parse_lines(lines) do
    lines
    |> Enum.reduce(%{}, fn line, acc ->
      case parse_one_line(line) do
        :end_of_stream ->
          acc

        {:station, station_num, station_name} ->
          station = {station_num, station_name}
          Map.update(acc, :stations, [station], &[station | &1])

        {key, val} when is_atom(key) ->
          Map.put(acc, key, val)

        :ignore ->
          acc
      end
    end)
  end

  for {string, atom} <- @attributes do
    defp parse_one_line(unquote(string) <> "=" <> artist), do: {unquote(atom), artist}
  end

  defp parse_one_line("END_STREAM"), do: :end_of_stream

  defp parse_one_line("station" <> rest) do
    {station_number, "=" <> station_name} = Integer.parse(rest, 10)
    {:station, station_number, station_name}
  end

  defp parse_one_line(line) when line in ["stationfetchplaylist", "songfinish", "songstart"] do
    :ignore
  end

  # TODO: Support usergetstations
  # Also: Currently supported events are: artistbookmark, songban, songbookmark,
  # songexplain, songfinish, songlove, songmove, songshelf, songstart,
  # stationaddgenre, stationaddmusic, stationaddshared, stationcreate,
  # stationdelete, stationdeleteartistseed, stationdeletefeedback,
  # stationdeletesongseed, stationfetchinfo, stationfetchplaylist,
  # stationfetchgenre stationquickmixtoggle, stationrename, userlogin,
  # usergetstations
end
