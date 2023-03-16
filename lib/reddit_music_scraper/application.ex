defmodule RedditMusicScraper.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: RedditMusicScraper.Router, options: [port: 8888]}
    ]

    IO.puts("🎧 on http://localhost:8888")

    opts = [strategy: :one_for_one, name: RedditMusicScraper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
