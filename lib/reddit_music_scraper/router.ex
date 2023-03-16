defmodule RedditMusicScraper.Router do
  use Plug.Router

  alias RedditMusicScraper.Spotify

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "🎧 Reddit Music Scraper")
  end

  get "/callback" do
    {:ok, %{"access_token" => access_token, "refresh_token" => refresh_token}} =
      conn.query_string
      |> String.split("=")
      |> List.last()
      |> Spotify.get_token()

    System.put_env("SPOTIFY_ACCESS_TOKEN", access_token)
    System.put_env("SPOTIFY_REFRESH_TOKEN", refresh_token)

    conn
    |> send_resp(200, "Spotify auth callback")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
