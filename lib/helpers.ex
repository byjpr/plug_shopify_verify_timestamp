defmodule PlugShopifyVerifyTimestamp.Helper do
  @moduledoc """
  Halt helper
  """
  import Plug.Conn

  def halt_on_error?(conn, true, pass_signal) do
    case conn.private[pass_signal] do
      false ->
        conn |> halt()

      true ->
        conn
    end
  end

  def halt_on_error?(conn, false, _pass_signal) do
    conn
  end

  def get_param_from_url(conn, %{param: key}), do: get_param_from_url(conn, key)

  def get_param_from_url(conn, key) when is_atom(key),
    do: get_param_from_url(conn, Atom.to_string(key))

  def get_param_from_url(conn, key), do: conn.params[key]

  def get_param_from_header(conn, key), do: get_req_header(conn, key)
end
