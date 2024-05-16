defmodule Shelly.Mqtt.Handler do
  use Tortoise.Handler

  alias Shelly.Cloud

  @spec handle_message(list(String), String.t(), any()) :: {:ok, any}
  def handle_message(["shellies", device_name, "relay", "0", "energy"], value, state) do
    {:ok, %{device: device}} =
      String.to_integer(value, 10)
      |> Cloud.insert_hourly_report(device_name)

    Cloud.broadcast_device(device)

    {:ok, state}
  end
end
