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

  def read_file() do
    case File.read(input_file()) do
      {:ok, input} ->
        IO.puts "with ok!"
        {:ok, parse(input)}

      {:error, msg} ->
        IO.inspect(msg, label: "error msg")
        {:error, msg}
    end
  end

  def parse(input) do
    lines = String.split(input, "\n", trim: true)
    [event_name | lines] = lines

    parse_lines(lines)
    |> Map.put(:event_name, event_name)
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

  defp input_file, do: "/Users/jason/dev/piano_ex/input.pipe"
end
