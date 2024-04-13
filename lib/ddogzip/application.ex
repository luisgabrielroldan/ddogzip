defmodule DDogZip.Application do
  @moduledoc false

  alias DDogZip.{Config, Router}

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    api_port = Config.get_dd_trace_port()
    zipkin_host = Config.get_zipkin_host()
    zipkin_port = Config.get_zipkin_port()

    app_version = Application.spec(:ddogzip)[:vsn]

    Logger.info("Starting DataDog v#{app_version} trace agent on port #{api_port}")
    Logger.info("Zipkin target: #{zipkin_host}:#{zipkin_port}")

    children = [
      {Bandit, plug: Router, scheme: :http, port: api_port}
    ]

    opts = [strategy: :one_for_one, name: DDogZip.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
