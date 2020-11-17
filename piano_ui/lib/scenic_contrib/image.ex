defmodule ScenicContrib.Image do
  @moduledoc """
  At compile-time loads the image to compute the hash, calculates the path
  relative to the priv directory. Recomputes the path at runtime so that it is
  compatible with releases (especially Nerves)
  """

  defmacro __using__({otp_app, path_fragment}) do
    quote do
      # @behaviour ScenicContrib.Image
      import ScenicContrib.Image

      @path :code.priv_dir(unquote(otp_app))
            |> Path.join(unquote(path_fragment))

      @external_resource @path
      @hash Scenic.Cache.Support.Hash.file!(@path, :sha)

      def compile_path do
        @path
      end

      def compile_hash do
        @hash
      end

      def load(opts \\ []) do
        {:ok, @hash} =
          runtime_path()
          |> Scenic.Cache.Static.Texture.load(@hash, opts)
      end

      def runtime_path do
        :code.priv_dir(unquote(otp_app))
        |> Path.join(unquote(path_fragment))
      end
    end
  end
end
