defmodule PianoUi.Demo do
  def display_song do
    song = %PianoCtl.Models.Song{
      album: "Unlimited",
      artist: "Bassnectar",
      cover_art_url:
        "http://cont-1.p-cdn.us/images/c9/fd/90/3a/33634d3caf7beafdbf103390/1080W_1080H.jpg",
      title: "Journey To The Center"
    }

    PianoUi.Scene.Splash.update_song(song)
  end
end
