defmodule PianoUi.MeetingBehaviour do
  @callback start_meeting() :: any
  @callback finish_meeting() :: any
end

defmodule PianoUi.KeylightBehaviour do
  @callback on() :: any()
  @callback off() :: any()
  @callback reset() :: any()

  # Brightness goes from 0 to 100 (values outside of the range are ignored and 0 appears to turn the light off)
  # Temperature goes from 145 to 344
  @type set_opts :: [{:brightness, non_neg_integer()} | {:temperature, non_neg_integer()}]
  @callback set(opts :: set_opts) :: any()

  @callback status() :: {:ok, %{
              brightness: non_neg_integer(),
              temperature: non_neg_integer(),
              on: integer()
            }} | {:error, any()}
end
