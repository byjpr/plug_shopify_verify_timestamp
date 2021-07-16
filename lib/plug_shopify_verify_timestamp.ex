defmodule PlugShopifyVerifyTimestamp do
  @moduledoc """
  Validate the time difference supplied in URL Parameters by Shopify.
  """
  import Plug.Conn

  def init(options), do: options

  def call(
        %{private: %{shop_origin_type: :url}} = conn,
        [max_delta: max_delta, halt_on_error: halt?] = _opts
      ),
      do:
        conn
        |> put_private(:enron_timestamp_now, DateTime.utc_now() |> DateTime.to_unix())
        |> shopify_timestamp
        |> delta
        |> validation(max_delta)
        |> EnronWeb.Plug.Helper.halt_on_error?(halt?, :enron_passed_timestamp_verification)

  def call(conn, _), do: conn

  def shopify_timestamp(conn) do
    timestamp = conn |> Enron.Helper.get_param_from_url("timestamp") |> ensure_integer

    put_private(conn, :enron_timestamp_shopify, timestamp)
  end

  defp ensure_integer(value) when is_binary(value) do
    value |> String.to_integer()
  end

  defp ensure_integer(value) when is_nil(value) do
    0
  end

  def delta(conn) do
    now = conn.private[:enron_timestamp_now] |> DateTime.from_unix!()
    sent = conn.private[:enron_timestamp_shopify] |> DateTime.from_unix!()

    put_private(conn, :enron_timestamp_delta, DateTime.diff(now, sent))
  end

  def validation(%{private: %{enron_timestamp_delta: delta}} = conn, max_delta)
      when not (delta >= max_delta),
      do: conn |> put_private(:enron_passed_timestamp_verification, true)

  def validation(conn, _),
    do: conn |> put_private(:enron_passed_timestamp_verification, false)
end
