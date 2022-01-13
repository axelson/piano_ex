defmodule PianoUi.MockCalendarFetcher do
  def read_calendars(_calendar_urls) do
    body = File.read!(Path.join([__DIR__, "..", "..", "sample_data", "us_holidays.ics"]))

    ICalendar.from_ics(body, ignore_errors: true)
  end
end
