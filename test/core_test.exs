defmodule DDogZip.CoreTest do
  use ExUnit.Case

  alias DDogZip.Core

  describe "dd_decode/1" do
    test "decodes encoded data successfully" do
      dd_data = [
        [
          %{
            "span_id" => "1",
            "trace_id" => "2",
            "parent_id" => "0",
            "name" => "test",
            "start" => 1_000_000,
            "duration" => 500_000,
            "service" => "service-name",
            "resource" => "resource-name",
            "error" => 0,
            "type" => "web",
            "meta" => %{}
          }
        ]
      ]

      encoded_data = Msgpax.pack!(dd_data)
      assert Core.dd_decode(encoded_data) == {:ok, dd_data}
    end

    test "returns an error on decode failure" do
      encoded_data = "invalid"
      assert Core.dd_decode(encoded_data) == {:error, :decode}
    end
  end

  describe "dd_to_zipkin/1" do
    test "converts dd data to zipkin data format" do
      dd_data = [
        [
          %{
            "span_id" => 1,
            "trace_id" => 2,
            "parent_id" => 0,
            "name" => "test",
            "start" => 1_000_000,
            "duration" => 500_000,
            "service" => "service-name",
            "resource" => "resource-name",
            "error" => 0,
            "type" => "web",
            "meta" => %{}
          }
        ]
      ]

      expected_output = [
        %{
          "id" => "1",
          "traceId" => "2",
          "parentId" => "0",
          "name" => "test",
          "timestamp" => 1000,
          "duration" => 500,
          "tags" => %{
            "dd.resource" => "resource-name",
            "dd.error" => 0,
            "dd.type" => "web"
          },
          "localEndpoint" => %{"serviceName" => "service-name"}
        }
      ]

      assert Core.dd_to_zipkin(dd_data) == expected_output
    end
  end
end
