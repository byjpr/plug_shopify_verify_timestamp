defmodule PlugShopifyVerifyTimestampTest do
  use ExUnit.Case
  doctest PlugShopifyVerifyTimestamp

  @moduledoc """
  Test the plug that verifies time difference supplied in URL Parameters by Shopify.
  """

  use Enron.ConnCase
  use Timex
  alias EnronWeb.{Plug, Router}

  setup _config do
    conn = bypass_through(build_conn(), Router, :browser)

    {:ok, %{conn: conn}}
  end

  test "halts connections without parameter", %{conn: conn} do
    config = [max_delta: 5, halt_on_error: true]

    conn =
      conn
      |> put_private(:shop_origin_type, :url)
      |> get("/new")
      |> Enron.URLAuthTime.call(config)

    assert conn.halted
  end

  test "halts connections with time delay", %{conn: conn} do
    config = [max_delta: 5, halt_on_error: true]
    datetime = Timex.now() |> Timex.shift(seconds: -6) |> Timex.to_unix()

    conn =
      conn
      |> put_private(:shop_origin_type, :url)
      |> get("/new?test_param=param&timestamp=#{datetime}")
      |> Enron.URLAuthTime.call(config)

    assert conn.halted
  end

  test "1 second delay with a max delta of 5 should not be halted", %{conn: conn} do
    config = [max_delta: 5, halt_on_error: true]
    datetime = Timex.now() |> Timex.shift(seconds: -1) |> Timex.to_unix()

    conn =
      conn
      |> put_private(:shop_origin_type, :url)
      |> get("/new?test_param=param&timestamp=#{datetime}")
      |> Enron.URLAuthTime.call(config)

    refute conn.halted
  end

  test "2 second delay with a max delta of 5 should not be halted", %{conn: conn} do
    config = [max_delta: 5, halt_on_error: true]
    datetime = Timex.now() |> Timex.shift(seconds: -2) |> Timex.to_unix()

    conn =
      conn
      |> put_private(:shop_origin_type, :url)
      |> get("/new?test_param=param&timestamp=#{datetime}")
      |> Enron.URLAuthTime.call(config)

    refute conn.halted
  end

  test "3 second delay with a max delta of 5 should not be halted", %{conn: conn} do
    config = [max_delta: 5, halt_on_error: true]
    datetime = Timex.now() |> Timex.shift(seconds: -3) |> Timex.to_unix()

    conn =
      conn
      |> put_private(:shop_origin_type, :url)
      |> get("/new?test_param=param&timestamp=#{datetime}")
      |> Enron.URLAuthTime.call(config)

    refute conn.halted
  end

  test "4 second delay with a max delta of 5 should not be halted", %{conn: conn} do
    config = [max_delta: 5, halt_on_error: true]
    datetime = Timex.now() |> Timex.shift(seconds: -4) |> Timex.to_unix()

    conn =
      conn
      |> put_private(:shop_origin_type, :url)
      |> get("/new?test_param=param&timestamp=#{datetime}")
      |> Enron.URLAuthTime.call(config)

    refute conn.halted
  end

  test "5 second delay with a max delta of 5 should be halted", %{conn: conn} do
    config = [max_delta: 5, halt_on_error: true]
    datetime = Timex.now() |> Timex.shift(seconds: -5) |> Timex.to_unix()

    conn =
      conn
      |> put_private(:shop_origin_type, :url)
      |> get("/new?test_param=param&timestamp=#{datetime}")
      |> Enron.URLAuthTime.call(config)

    assert conn.halted
  end
end
