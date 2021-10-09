defmodule PianoUi.FileCache do
  @max_files 5

  @moduledoc """
  A very simple FileCache that stores up to #{@max_files} and if that number is
  exceeded, clears the oldest files above the limit.
  """

  require Logger

  def has?(file_name) do
    File.exists?(file_path(file_name))
  end

  def put(file_name, file_content) do
    File.mkdir_p!(cache_dir())
    maybe_clear_directory()

    File.write(file_path(file_name), file_content)
  end

  def read(file_name) do
    File.read(file_path(file_name))
  end

  defp file_path(file_name) do
    sha =
      :crypto.hash(:sha256, file_name)
      |> Base.encode16()

    Path.join([cache_dir(), sha])
  end

  defp maybe_clear_directory do
    case cached_files() do
      files when length(files) > @max_files ->
        remove_excess_files(files)

      _ ->
        nil
    end
  end

  defp remove_excess_files(files) when length(files) > @max_files do
    [file | rest] = files
    result = File.rm(file)
    Logger.info("Removed excess file with result: #{inspect(result)}")
    remove_excess_files(rest)
  end

  defp remove_excess_files(_), do: :ok

  defp cached_files do
    File.ls!(cache_dir())
    |> Enum.map(&Path.join(cache_dir(), &1))
    |> Enum.sort_by(fn file -> File.stat!(file).ctime end)
  end

  defp cache_dir do
    Application.fetch_env!(:piano_ui, :album_cache_dir)
  end
end
