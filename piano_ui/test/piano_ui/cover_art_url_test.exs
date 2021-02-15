defmodule PianoUi.CoverArtUrlTest do
  use ExUnit.Case, async: true

  alias PianoUi.CoverArtUrl

  describe "adjust_size/1" do
    import CoverArtUrl, only: [adjust_size: 1]

    test "doesn't change 500px images" do
      url = "http://cont-1.p-cdn.us/images/c9/fd/90/3a/33634d3caf7beafdbf103390/500W_500H.jpg"
      assert adjust_size(url) == url
    end

    test "converts 1080px to 500px" do
      url = "http://cont-1.p-cdn.us/images/c9/fd/90/3a/33634d3caf7beafdbf103390/1080W_1080H.jpg"

      assert adjust_size(url) ==
               "http://cont-1.p-cdn.us/images/c9/fd/90/3a/33634d3caf7beafdbf103390/500W_500H.jpg"
    end

    test "with an image that doesn't match" do
      url = "http://google.com"
      assert adjust_size(url) == url
    end
  end
end
