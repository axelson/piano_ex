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

  @next_song_attributes ~w(artist title album coverArt rating detailUrl songDuration)

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
      field :next_songs, [map()], default: []
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
    result =
      lines
      |> Enum.reduce(%{}, fn line, acc ->
        case parse_one_line(line) do
          :end_of_stream ->
            acc

          {:station, station_num, station_name} ->
            station = {station_num, station_name}
            Map.update(acc, :stations, [station], &[station | &1])

          {:next_song, index, key, value} ->
            next_songs = Map.get(acc, :next_songs, %{})
            song = Map.get(next_songs, index, %{})
            song = Map.put(song, key, value)
            Map.put(acc, :next_songs, Map.put(next_songs, index, song))

          {key, val} when is_atom(key) ->
            Map.put(acc, key, val)

          :ignore ->
            acc
        end
      end)

    case Map.get(result, :next_songs) do
      nil ->
        result

      next_songs_map ->
        sorted = next_songs_map |> Enum.sort_by(&elem(&1, 0)) |> Enum.map(&elem(&1, 1))
        Map.put(result, :next_songs, sorted)
    end
  end

  for {string, atom} <- @attributes do
    defp parse_one_line(unquote(string) <> "=" <> artist), do: {unquote(atom), artist}
  end

  for attr <- @next_song_attributes do
    defp parse_one_line(unquote(attr) <> "Next" <> rest) do
      {index, "=" <> value} = Integer.parse(rest, 10)

      {:next_song, index, unquote(@attributes[attr] || String.to_atom(Macro.underscore(attr))),
       value}
    end
  end

  defp parse_one_line("END_STREAM"), do: :end_of_stream

  defp parse_one_line("station" <> rest) do
    {station_number, "=" <> station_name} = Integer.parse(rest, 10)
    {:station, station_number, station_name}
  end

  defp parse_one_line(line) when line in ["stationfetchplaylist", "songfinish", "songstart"] do
    :ignore
  end
end
