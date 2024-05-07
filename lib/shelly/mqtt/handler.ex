defmodule Shelly.Mqtt.Handler do
  use Tortoise.Handler

  alias Shelly.Cloud

  def init(args) do
    {:ok, args}
  end

  def connection(_status, state) do
    # `status` will be either `:up` or `:down`; you can use this to
    # inform the rest of your system if the connection is currently
    # open or closed; tortoise should be busy reconnecting if you get
    # a `:down`
    {:ok, state}
  end

  @spec handle_message(list(String), String.t(), any()) :: {:ok, any}
  def handle_message(["shellies", device_name, "relay", "0", "energy"], value, state) do
    {:ok, %{device: device}} =
      String.to_integer(value, 10)
      |> Cloud.insert_hourly_report(device_name)

    Cloud.broadcast_device(device)

    {:ok, state}
  end

  def handle_message(_topic, _payload, state) do
    {:ok, state}
  end

  def subscription(_status, _topic_filter, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end
end
