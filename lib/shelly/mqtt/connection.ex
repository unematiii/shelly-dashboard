defmodule Shelly.Mqtt.Connection do
  def start_link(_opts) do
    env = Application.fetch_env!(:shelly, __MODULE__)
    opts = connection_options(env)

    adapter(env).start_link(opts)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  defp adapter(env) do
    Keyword.fetch!(env, :adapter)
  end

  defp connection_options(env) do
    [
      client_id: "shelly",
      server:
        {Tortoise.Transport.Tcp,
         host: Keyword.fetch!(env, :hostname), port: Keyword.fetch!(env, :port)},
      user_name: Keyword.fetch!(env, :username),
      password: Keyword.fetch!(env, :password),
      handler: {Shelly.Mqtt.Handler, []},
      subscriptions: [{Keyword.fetch!(env, :topic), 0}]
    ]
  end
end
