use Mix.Config

config :cache, otp: [max_restarts: 1, max_seconds: 1]
config :cache, eviction_policy: %{
  type: :lru,
  threshold: 1_000
}
# config :cache, eviction_policy: %{
#   type: :none,
#   threshold: 1_000
# }
