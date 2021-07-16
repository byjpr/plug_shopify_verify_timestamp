defmodule PlugShopifyVerifyTimestamp do
  @moduledoc """
  Validate the time difference supplied in URL Parameters by Shopify.
  """
  import Plug.Conn

  @spec init(any) :: any
  def init(options), do: options

  @spec call(Plug.Conn.t(), nonempty_list(max_delta: integer(), halt_on_error: boolean())) ::
          Plug.Conn.t()
  def call(
        %{private: %{shop_origin_type: :url}} = conn,
        [max_delta: max_delta, halt_on_error: halt?] = _opts
      ),
      do:
        conn
        |> put_private(:psv_timestamp_now, DateTime.utc_now() |> DateTime.to_unix())
        |> shopify_timestamp
        |> delta
        |> validation(max_delta)
        |> PlugShopifyVerifyTimestamp.Helper.halt_on_error?(
          halt?,
          :psv_passed_timestamp_verification
        )

  def call(conn, _), do: conn

  @spec shopify_timestamp(Plug.Conn.t()) :: Plug.Conn.t()
  def shopify_timestamp(conn) do
    timestamp =
      conn |> PlugShopifyVerifyTimestamp.Helper.get_param_from_url("timestamp") |> ensure_integer

    put_private(conn, :psv_timestamp_shopify, timestamp)
  end

  defp ensure_integer(value) when is_binary(value) do
    value |> String.to_integer()
  end

  defp ensure_integer(value) when is_nil(value) do
    0
  end

  @spec delta(Plug.Conn.t()) :: Plug.Conn.t()
  def delta(conn) do
    now = conn.private[:psv_timestamp_now] |> DateTime.from_unix!()
    sent = conn.private[:psv_timestamp_shopify] |> DateTime.from_unix!()

    put_private(conn, :psv_timestamp_delta, DateTime.diff(now, sent))
  end

  @spec validation(Plug.Conn.t(), integer()) :: Plug.Conn.t()
  def validation(%{private: %{psv_timestamp_delta: delta}} = conn, max_delta)
      when not (delta >= max_delta),
      do: conn |> put_private(:psv_passed_timestamp_verification, true)

  def validation(conn, _),
    do: conn |> put_private(:psv_passed_timestamp_verification, false)
end
