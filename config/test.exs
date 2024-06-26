import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :shelly, Shelly.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "shelly_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# MQTT options
config :shelly, Shelly.Mqtt.Connection,
  adapter: Shelly.MQTTConnectionMock,
  username: "user",
  password: "password",
  hostname: "localhost",
  port: 1883,
  topic: "shellies/+/relay/0/energy"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :shelly, ShellyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "gFTnbS+XbUgtahQbMHD9w8ZrMKVfq7N2uAVzL7QUvXxBCSx31f35u/b2DRvYT37K",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true
