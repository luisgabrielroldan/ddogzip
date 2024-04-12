import Config

config :ddogzip,
  dd_trace_port: System.get_env("DDTRACE_PORT", "8126") |> String.to_integer(),
  zipkin_host: System.get_env("ZIPKIN_HOST", "localhost"),
  zipkin_port: System.get_env("ZIPKIN_PORT", "9411") |> String.to_integer()

parse_log_level! = fn value ->
  if value in ~w(debug info warn error) do
    String.to_atom(value)
  else
    raise ArgumentError, "Invalid log level: #{value}"
  end
end

config :logger,
  level: System.get_env("LOG_LEVEL", "info") |> parse_log_level!.()
