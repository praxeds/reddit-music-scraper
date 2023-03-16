defmodule RedditMusicScraper.Spotify do
  def authorize do
    "https://accounts.spotify.com/authorize?" <>
      "client_id=#{client_id()}" <>
      "&response_type=code" <>
      "&redirect_uri=#{callback_url()}" <>
      "&scope=#{scopes()}"
  end

  def get_token(auth) do
    url = "https://accounts.spotify.com/api/token"

    headers = %{
      "Content-Type" => "application/x-www-form-urlencoded",
      "Authorization" => "Basic " <> Base.encode64(client_id() <> ":" <> client_secret())
    }

    body = "grant_type=authorization_code&code=#{auth}&redirect_uri=#{callback_url()}"

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "Spotify API returned #{status} with body: #{body}"}

      {:error, error} ->
        {:error, error}
    end
  end

  def create_playlist(title, description \\ "", public \\ true) do
    headers = [
      {"Authorization", "Bearer " <> System.get_env("SPOTIFY_ACCESS_TOKEN")},
      {"Content-Type", "application/json"}
    ]

    body =
      Jason.encode!(%{
        "name" => title,
        "description" => description,
        "public" => public
      })

    response =
      HTTPoison.post("https://api.spotify.com/v1/users/#{user_id()}/playlists", body, headers)

    case response do
      {:ok, %{body: body}} ->
        playlist_id = Jason.decode!(body)["id"]
        {:ok, playlist_id}

      {:error, _} ->
        {:error, "Request failed"}
    end
  end

  def search_track(track) do
    headers = [
      {"Authorization", "Bearer " <> System.get_env("SPOTIFY_ACCESS_TOKEN")},
      {"Content-Type", "application/json"}
    ]

    query_params = "q=#{URI.encode_www_form(track)}&type=track&limit=1"

    response = HTTPoison.get("https://api.spotify.com/v1/search?" <> query_params, headers)

    case response do
      {:ok, %{body: body}} ->
        tracks = Jason.decode!(body)["tracks"]["items"]

        if Enum.empty?(tracks) do
          {:error, "No tracks found"}
        else
          track_uri = tracks |> Enum.at(0) |> Map.get("uri")
          {:ok, track_uri}
        end

      {:error, _} ->
        {:error, "Request failed"}
    end
  end

  def add_tracks(playlist_id, songs) do
    headers = [
      {"Authorization", "Bearer " <> System.get_env("SPOTIFY_ACCESS_TOKEN")},
      {"Content-Type", "application/json"}
    ]

    body = Jason.encode!(%{"uris" => songs})

    response =
      HTTPoison.post("https://api.spotify.com/v1/playlists/#{playlist_id}/tracks", body, headers)

    case response do
      {:ok, %{status_code: 201}} ->
        {:ok, "Playlist created successfully"}

      {:ok, %{status_code: status}} ->
        {:error, "Spotify API returned #{status}"}

      {:error, error} ->
        {:error, error}
    end
  end

  defp scopes do
    Application.get_env(:reddit_music_scraper, :scopes)
    |> Enum.join(" ")
    |> URI.encode()
  end

  defp callback_url do
    Application.get_env(:reddit_music_scraper, :callback_url) |> URI.encode_www_form()
  end

  defp client_id, do: Application.get_env(:reddit_music_scraper, :client_id)

  defp user_id, do: Application.get_env(:reddit_music_scraper, :user_id)

  defp client_secret, do: Application.get_env(:reddit_music_scraper, :client_secret)
end
