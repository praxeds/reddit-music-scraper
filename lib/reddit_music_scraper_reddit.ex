defmodule RedditMusicScraper.Reddit do
  def fetch_next_pages(_url, 0), do: []

  def fetch_next_pages(url, n) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: body}} ->
        {:ok, document_content} = Floki.parse_document(body)

        next_page_url =
          document_content
          |> Floki.find("span.next-button a")
          |> Floki.attribute("href")

        case next_page_url do
          [url] when n > 0 ->
            [url | fetch_next_pages(url, n - 1)]

          _ ->
            []
        end
    end
  end

  # função pra pegar a url da página x pra usar ela como base pra pegar as próximas
  def fetch_n_page(subreddit_url, n) do
    case HTTPoison.get(subreddit_url) do
      {:ok, %HTTPoison.Response{body: body}} ->
        {:ok, document_content} = Floki.parse_document(body)

        n_page_url =
          document_content
          |> Floki.find("span.next-button a")
          |> Floki.attribute("href")

        case n_page_url do
          [url] when n > 0 ->
            fetch_n_page(url, n - 1)

          _ ->
            subreddit_url
        end
    end
  end

  def fetch_songs_titles(url, pages) do
    IO.puts("🎧")
    IO.puts("=======================================")

    # Adds the first page to the list of pages
    pages = [url] ++ fetch_next_pages(url, pages)

    pages
    |> Enum.map(fn url ->
      case HTTPoison.get(url) do
        {:ok, %HTTPoison.Response{body: body}} ->
          {:ok, document_content} = Floki.parse_document(body)

          songs =
            document_content
            |> Floki.find("a.title[data-href-url*='youtu']")
            |> Enum.map(&Floki.text/1)

          {:ok, songs}
      end
    end)
    # concats all the songs into a single list
    |> Enum.reduce([], fn {:ok, songs}, song_list -> songs ++ song_list end)
  end

  # Pra ser usado com YouTube

  # def fetch_songs_urls(url, pages) do
  #   IO.puts("🎧")
  #   IO.puts("=======================================")

  #   # Adds the first page to the list of pages
  #   pages = [url] ++ fetch_next_pages(url, pages)

  #   pages
  #   |> Enum.map(fn url ->
  #     case HTTPoison.get(url) do
  #       {:ok, %HTTPoison.Response{body: body}} ->
  #         {:ok, document_content} = Floki.parse_document(body)

  #         songs =
  #           document_content
  #           |> Floki.find("a.title")
  #           |> Floki.attribute("data-href-url")
  #           # Filter out non-youtube links
  #           |> Enum.filter(fn url -> String.contains?(url, "youtu") end)

  #         {:ok, songs}
  #     end
  #   end)
  #   # concats all the songs into a single list
  #   |> Enum.reduce([], fn {:ok, songs}, song_list -> songs ++ song_list end)
  # end
end
