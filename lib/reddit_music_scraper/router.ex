defmodule RedditMusicScraper.Router do
  use Plug.Router

  alias RedditMusicScraper.Spotify
  alias RedditMusicScraper.Youtube

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> send_resp(200, "Reddit Music Scraper")
  end

  # Spotify auth
  get "/callback" do
    {:ok, %{"access_token" => access_token, "refresh_token" => refresh_token}} =
      conn.query_string
      |> String.split("=")
      |> List.last()
      |> Spotify.get_token()

    System.put_env("SPOTIFY_ACCESS_TOKEN", access_token)
    System.put_env("SPOTIFY_REFRESH_TOKEN", refresh_token)

    conn
    |> IO.inspect()
    |> send_resp(200, "Spotify auth callback")
  end

  # Youtube auth
  get "/consent" do
    {:ok, %{"access_token" => access_token, "refresh_token" => refresh_token}} =
      conn.query_string
      |> String.split("&")
      |> List.first()
      |> String.split("=")
      |> List.last()
      |> Youtube.get_token()

    System.put_env("YOUTUBE_ACCESS_TOKEN", access_token)
    System.put_env("YOUTUBE_REFRESH_TOKEN", refresh_token)

    conn
    |> send_resp(200, "Youtube auth consent")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
