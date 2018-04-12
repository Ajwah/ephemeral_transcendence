use Mix.Config

config :cache, otp: [max_restarts: 1, max_seconds: 1]
config :cache, eviction_policy: %{
  type: :lru,
  threshold: 10_000
}
