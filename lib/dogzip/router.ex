defmodule DDogZip.Router do
  use Plug.Router

  require Logger

  alias DDogZip.{Core, ZipkinClient}

  plug(:match)
  plug(:dispatch)

  put "/v0.3/traces" do
    with {:ok, ddpayload, conn} <- Plug.Conn.read_body(conn),
         {:ok, ddata} <- Core.dd_decode(ddpayload) do
      :ok =
        ddata
        |> Core.dd_to_zipkin()
        |> ZipkinClient.send()

      send_resp(conn, 200, "Ok")
    else
      error ->
        Logger.error("Endpoint error: #{inspect(error)}")

        send_resp(conn, 400, "Error")
    end
  end

  match _ do
    Logger.error("Invalid request: #{conn.method} /#{Enum.join(conn.path_info, "/")}")
    send_resp(conn, 404, "not found")
  end
end
