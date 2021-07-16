# PlugShopifyVerifyTimestamp

When Shopify embeds your app into the Shopify Admin it also includes a bunch of variables in URL Parameters. Those are `shop`, `timestamp` and `hmac`. Together these variables allow you to verify the legitimacy of a request. This package allows you to verify the "timestamp" component (it does not validate it against the hmac) has not elapsed a configured window.

## Usage
In the pipeline you would like to timestamp verify, add `plug PlugShopifyVerifyTimestamp, max_delta: 5, halt_on_error: true` to create a 5 second grace period between the request being sent and it being recieved.

```elixir
pipeline :embedded do
  plug PlugShopifyVerifyTimestamp, max_delta: 5, halt_on_error: true
end
```

## Installation

The package can be installed by adding `plug_shopify_verify_timestamp`
to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:plug_shopify_verify_timestamp, "~> 0.1.0"}
  ]
end
```