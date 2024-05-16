defmodule Shelly.Mqtt.HandlerTest do
  use Shelly.DataCase

  import Shelly.CloudFixtures

  alias Shelly.Cloud
  alias Shelly.Mqtt.Handler
  alias Shelly.Schemas.{Device, Report}

  @default_state %{option: "value"}

  describe "handler" do
    test "handle_message/3 handles report from device" do
      device = %Device{id: device_id} = device_fixture()
      value = "150"

      Cloud.subscribe_to_device(device_id)

      assert {:ok, @default_state} =
               Handler.handle_message(
                 ["shellies", device.name, "relay", "0", "energy"],
                 value,
                 @default_state
               )

      assert_receive {:device, %Device{id: ^device_id}}

      assert %Device{total: 150, last_reported: 150} = Cloud.get_by_name(device.name)
      assert %Report{total: 150} = Cloud.get_hourly_report(device.name)
    end
  end
end
