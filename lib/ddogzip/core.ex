defmodule DDogZip.Core do
  @moduledoc """
  This module provides functionalities to decode data and convert it into a
  format compatible with Zipkin for tracing distributed systems.
  """

  require Logger
  alias Msgpax, as: Encoder

  @type dd_span :: %{binary() => term()}
  @type dd_data :: [[dd_span()]]
  @type zipkin_span :: map()
  @type zipkin_data :: [zipkin_span()]

  @spec dd_decode(iodata()) :: {:ok, dd_data()} | {:error, :decode}
  def dd_decode(encoded_data) do
    encoded_data
    |> Encoder.unpack()
    |> handle_unpack_response()
  end

  @spec handle_unpack_response({:ok, any()} | {:error, any()}) ::
          {:ok, dd_data()} | {:error, :decode}
  defp handle_unpack_response({:ok, data}) when is_list(data), do: {:ok, data}
  defp handle_unpack_response({:error, _reason}), do: {:error, :decode}

  @spec dd_to_zipkin(dd_data()) :: zipkin_data()
  def dd_to_zipkin(data) do
    zipkin_data =
      data
      |> List.flatten()
      |> Enum.map(&build_zipkin_span/1)

    trace_ids = Enum.map(zipkin_data, & &1["traceId"]) |> Enum.uniq()
    Logger.debug("Trace IDs: #{inspect(trace_ids)}")

    zipkin_data
  end

  @spec build_zipkin_span(dd_span()) :: zipkin_span()
  defp build_zipkin_span(ddspan) when is_map(ddspan) do
    tags =
      ddspan
      |> Map.get("meta", %{})
      |> Map.merge(%{
        "dd.resource" => ddspan["resource"],
        "dd.error" => ddspan["error"] |> to_string(),
        "dd.type" => ddspan["type"]
      })

    %{
      "id" => ddspan["span_id"] |> to_zipkin_id(),
      "traceId" => ddspan["trace_id"] |> to_zipkin_id(),
      "parentId" => ddspan["parent_id"] |> to_zipkin_id(),
      "name" => ddspan["name"],
      "timestamp" => ddspan["start"] |> nanosec_to_microsec(),
      "duration" => ddspan["duration"] |> nanosec_to_microsec(),
      "tags" => tags,
      "localEndpoint" => %{"serviceName" => ddspan["service"]}
    }
    |> deep_remove_nils()
  end

  @spec to_zipkin_id(integer() | nil) :: nil | String.t()
  defp to_zipkin_id(nil), do: nil

  defp to_zipkin_id(id) when is_integer(id) do
    value = Integer.to_string(id, 16) |> String.downcase()
    pad = 16 - byte_size(value)
    String.duplicate("0", pad) <> value
  end

  @spec nanosec_to_microsec(integer()) :: integer()
  defp nanosec_to_microsec(nanosec), do: div(nanosec, 1_000)

  @spec deep_remove_nils(term) :: term
  defp deep_remove_nils(term) when is_map(term) do
    term
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Enum.map(fn {k, v} -> {k, deep_remove_nils(v)} end)
    |> Enum.into(%{})
  end

  defp deep_remove_nils(term) when is_list(term) do
    if Keyword.keyword?(term) do
      term
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.map(fn {k, v} -> {k, deep_remove_nils(v)} end)
    else
      Enum.map(term, &deep_remove_nils/1)
    end
  end

  defp deep_remove_nils(term), do: term
end
