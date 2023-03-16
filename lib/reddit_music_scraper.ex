defmodule RedditMusicScraper do
  alias RedditMusicScraper.Spotify
  alias RedditMusicScraper.Reddit

  # Tem que pedir auth e access token primeiro
  def playlist(
        subreddit \\ "https://old.reddit.com/r/80smusic/",
        pages,
        playlist_title,
        playlist_description \\ "",
        public \\ true
      ) do
    # Fetching songs from subreddit
    songs =
      Reddit.fetch_songs_titles(subreddit, pages)
      |> Enum.map(fn track ->
        case Spotify.search_track(track) do
          {:ok, track} ->
            track

          {:error, _} ->
            nil
        end
      end)
      # Making one list of songs
      |> List.flatten()

    # Creating playlist
    case Spotify.create_playlist(playlist_title, playlist_description, public) do
      {:ok, playlist_id} ->
        # Adding songs to playlist
        Spotify.add_tracks(playlist_id, songs)

      {:error, _} ->
        {:error, "Failed to create playlist"}
    end
  end
end
