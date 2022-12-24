defmodule PianoUi.MeetingBehaviour do
  @callback start_meeting() :: any
  @callback finish_meeting() :: any
end
