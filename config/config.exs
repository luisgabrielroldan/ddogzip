import Config

config :logger, :console,
  format: "[$level] $message\n",
  metadata: [:error_code, :file]

config :logger,
  backends: [:console]
