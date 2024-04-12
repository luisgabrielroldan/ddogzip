defmodule DDogZip.Config do
  @moduledoc false

  def get_dd_trace_port(),
    do: Application.get_env(:ddogzip, :dd_trace_port)

  def get_zipkin_host(),
    do: Application.get_env(:ddogzip, :zipkin_host)

  def get_zipkin_port(),
    do: Application.get_env(:ddogzip, :zipkin_port)
end
