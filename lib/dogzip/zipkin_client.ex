defmodule DDogZip.ZipkinClient do
  @moduledoc false

  alias DDogZip.Config
  alias DDogZip.Core

  require Logger

  @spec send(Core.zipkin_data()) :: :ok | {:error, HTTPoison.Error.t()}
  def send(zdata) do
    host = Config.get_zipkin_host()
    port = Config.get_zipkin_port()

    Logger.info("Sending #{length(zdata)} spans to Zipkin...")

    payload = Jason.encode!(zdata)

    %URI{
      host: host,
      port: port,
      scheme: "http",
      path: "/api/v2/spans"
    }
    |> URI.to_string()
    |> HTTPoison.post(payload, [
      {"content-type", "application/json"}
    ])
    |> case do
      {:ok, response} ->
        Logger.info("Zipkin response code: #{response.status_code} (#{length(zdata)} spans sent)")
        :ok

      {:error, error} ->
        Logger.error("Zipkin request failed! Error: #{inspect(error)}")
        Logger.debug("Payload: #{inspect(payload)}")
        {:error, error}
    end
  end
end
