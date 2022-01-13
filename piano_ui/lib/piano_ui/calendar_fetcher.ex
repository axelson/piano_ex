defmodule PianoUi.CalendarFetcher do
  @callback read_calendars([String.t()]) :: [%{}]

  def read_calendars(calendar_urls), do: impl().read_calendars(calendar_urls)

  defp impl, do: Application.fetch_env!(:piano_ui, :calendar_fetcher_impl)
end

defmodule PianoUi.CalendarFetcher.Impl do
  require Logger

  @behaviour PianoUi.CalendarFetcher

  @impl PianoUi.CalendarFetcher
  def read_calendars(calendar_urls) do
    calendar_urls
    |> Enum.reduce([], fn calendar_url, acc ->
      request = Finch.build(:get, calendar_url)

      case Finch.request(request, :piano_ui_finch) do
        {:ok, %Finch.Response{status: 200, body: body}} ->
          try do
            ICalendar.from_ics(body, ignore_errors: true) ++ acc
          rescue
            err ->
              Logger.error("Unable to parse ical: #{inspect(err)}")
              acc
          end

        err ->
          IO.inspect(err, label: "err (calendar_cache.ex:32)")
          acc
      end
    end)
  end
end
