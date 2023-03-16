defmodule RedditMusicScraper do
  alias RedditMusicScraper.Spotify
  alias RedditMusicScraper.Reddit
  alias RedditMusicScraper.Youtube

  # Tem que pedir auth e access token primeiro
  def spotify_playlist(
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

  def youtube_playlist(
        subreddit \\ "https://old.reddit.com/r/truecitypop/",
        pages,
        playlist_title,
        playlist_description \\ "",
        tags \\ [],
        public \\ true
      ) do
    # Creating playlist
    case Youtube.create_playlist(playlist_title, playlist_description, tags, public) do
      {:ok, playlist_id} ->
        # Fetching songs from subreddit

        Reddit.fetch_video_ids(subreddit, pages)
        |> Enum.map(fn track ->
          Youtube.add_video(playlist_id, track)
        end)

      {:error, _} ->
        {:error, "Failed to create playlist"}
    end
  end
end
