defmodule RedditMusicScraper.MixProject do
  use Mix.Project

  def project do
    [
      app: :reddit_music_scraper,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy],
      mod: {RedditMusicScraper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.6.0"},
      {:httpoison, "~> 2.1.0"},
      {:floki, "~> 0.34.0"},
      {:jason, "~> 1.4"}
    ]
  end
end
