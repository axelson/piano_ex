defmodule PianoUi.FileCache do
  @max_files 10

  @moduledoc """
  A very simple FileCache that stores up to #{@max_files} and if that number is
  exceeded, clears all the files.
  """

  def has?(file_name) do
    File.exists?(file_path(file_name))
  end

  def put(file_name, file_content) do
    File.mkdir_p!(cache_dir())
    maybe_clear_directory()

    File.write(file_path(file_name) |> IO.inspect(label: "file_path"), file_content)
  end

  def read(file_name) do
    File.read(file_path(file_name))
  end

  defp file_path(file_name) do
    sha =
      :crypto.hash(:sha, file_name)
      |> Base.encode16()

    Path.join([cache_dir(), sha])
  end

  defp maybe_clear_directory do
    case cached_files() do
      files when length(files) > @max_files ->
        Enum.each(files, fn file ->
          File.rm(file)
        end)

      _ ->
        nil
    end
  end

  defp cached_files do
    File.ls!(cache_dir())
  end

  defp cache_dir do
    Application.fetch_env!(:piano_ui, :album_cache_dir)
  end
end
