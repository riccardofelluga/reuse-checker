# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :reuse,
  ecto_repos: [Reuse.Repo],
  generators: [binary_id: true],
  machine_id: 1

# Configures the endpoint
config :reuse, ReuseWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2JcRsk8JRCveEo2Kd1phlsT4YyatiPmaALDduU8jA2fpOr6h6jfgSQKP7UR4GblE",
  render_errors: [view: ReuseWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Reuse.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id],
  # default, support for additional log sinks
  backends: [:console],
  # purges logs with lower level than this
  compile_time_purge_level: :debug

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
