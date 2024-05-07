defmodule Shelly.Mqtt.Connection do
  def start_link(_opts) do
    Tortoise.Connection.start_link(connection_options())
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  defp connection_options() do
    opts = Application.fetch_env!(:shelly, __MODULE__)

    [
      client_id: "shelly",
      server:
        {Tortoise.Transport.Tcp,
         host: Keyword.fetch!(opts, :hostname), port: Keyword.fetch!(opts, :port)},
      user_name: Keyword.fetch!(opts, :username),
      password: Keyword.fetch!(opts, :password),
      handler: {Shelly.Mqtt.Handler, []},
      subscriptions: [{Keyword.fetch!(opts, :topic), 0}]
    ]
  end
end
