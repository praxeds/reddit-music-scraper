defmodule RedditMusicScraper.Youtube do
  def authorize do
    "https://accounts.google.com/o/oauth2/auth?" <>
      "response_type=code" <>
      "&client_id=#{client_id()}" <>
      "&redirect_uri=#{callback_url()}" <>
      "&scope=#{scopes()}" <>
      "&access_type=offline" <>
      "&approval_prompt=force"
  end

  def get_token(code) do
    url = "https://oauth2.googleapis.com/token"

    headers = %{
      "Content-Type" => "application/x-www-form-urlencoded"
    }

    body =
      "code=#{code}" <>
        "&client_id=#{client_id()}" <>
        "&client_secret=#{client_secret()}" <>
        "&redirect_uri=#{callback_url()}" <>
        "&grant_type=authorization_code"

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, "Google API returned #{status} with body: #{body}"}

      {:error, error} ->
        {:error, error}
    end
  end

  def create_playlist(title, description \\ "", tags \\ [], public \\ true) do
    headers = [
      {"Authorization", "Bearer " <> System.get_env("YOUTUBE_ACCESS_TOKEN")},
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]

    body =
      Jason.encode!(%{
        "snippet" => %{
          "title" => title,
          "description" => description,
          "tags" => tags,
          "defaultLanguage" => "en"
        },
        "status" => %{
          "privacyStatus" => if(public, do: "public", else: "private")
        }
      })

    params = URI.encode_query(%{"part" => "snippet,status"})

    response =
      HTTPoison.post("https://www.googleapis.com/youtube/v3/playlists?#{params}", body, headers)

    case response do
      {:ok, %{body: body}} ->
        playlist_id = Jason.decode!(body)["id"]
        {:ok, playlist_id}

      {:error, error} ->
        {:error, error}
    end
  end

  def add_video(playlist_id, song) do
    headers = [
      {"Authorization", "Bearer " <> System.get_env("YOUTUBE_ACCESS_TOKEN")},
      {"Content-Type", "application/json"},
      {"Accept", "application/json"}
    ]

    body =
      Jason.encode!(%{
        "snippet" => %{
          "playlistId" => playlist_id,
          "position" => 0,
          "resourceId" => %{
            "kind" => "youtube#video",
            "videoId" => song
          }
        }
      })

    params = URI.encode_query(%{"part" => "snippet"})

    response =
      HTTPoison.post(
        "https://www.googleapis.com/youtube/v3/playlistItems?#{params}",
        body,
        headers
      )

    case response do
      {:ok, _body} ->
        {:ok, "Added successfully"}

      {:error, error} ->
        {:error, error}
    end
  end

  defp scopes do
    Application.get_env(:reddit_music_scraper, :youtube_scopes)
    |> Enum.join(" ")
    |> URI.encode()
  end

  defp callback_url do
    Application.get_env(:reddit_music_scraper, :youtube_callback_url) |> URI.encode_www_form()
  end

  defp client_id, do: Application.get_env(:reddit_music_scraper, :youtube_client_id)

  defp client_secret, do: Application.get_env(:reddit_music_scraper, :youtube_client_secret)
end
