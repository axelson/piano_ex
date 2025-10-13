defmodule PianoUi.MonitorControlBehaviour do
  @callback switch_to_desktop :: {:ok, term()} | {:error, term()}
  @callback switch_to_dock :: {:ok, term()} | {:error, term()}
  @callback gaming_desktop_turn_on_monitor :: {:ok, term()} | {:error, term()}
  @callback gaming_desktop_turn_off_monitor :: {:ok, term()} | {:error, term()}
end
