import Config

config :httpoison,
  # the timeout for HTTP requests, in milliseconds
  timeout: 5000,
  # the timeout for establishing a connection, in milliseconds
  connect_timeout: 5000,
  # whether to automatically follow redirects or not
  follow_redirect: true,
  # the maximum number of redirects to follow
  max_redirect: 5,
  # the maximum number of connections to keep open in the connection pool
  pool_size: 10

import_config("spotify_config.exs")
