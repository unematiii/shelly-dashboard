defmodule Shelly.CloudTest do
  use Shelly.DataCase

  alias Shelly.Cloud

  import Shelly.CloudFixtures

  describe "devices" do
    alias Shelly.Schemas.Device

    test "broadcast_device/1 subscribes to device updates" do
      device = %Device{id: device_id} = device_fixture()

      Cloud.subscribe_to_device(device_id)
      Cloud.broadcast_device(device)

      assert_receive {:device, %Device{id: ^device_id}}

      Cloud.unsubscribe_from_device(device_id)
      Cloud.broadcast_device(device)

      refute_receive {:device, %Device{}}
    end

    test "list_devices/0 returns all devices" do
      device = device_fixture()

      assert Cloud.list_devices() == [device]
    end

    test "get_device!/1 returns the device with given id" do
      device = device_fixture()

      assert Cloud.get_device!(device.id) == device
    end

    test "get_by_name/1 returns the device with given name" do
      device = device_fixture()

      assert Cloud.get_by_name(device.name) == device
    end

    test "create_device/1 with valid data creates a device" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Device{} = device} = Cloud.create_device(valid_attrs)
      assert device.name == "some name"
    end

    test "create_device/1 with invalid data returns error changeset" do
      invalid_attrs = %{name: nil}
      assert {:error, %Ecto.Changeset{}} = Cloud.create_device(invalid_attrs)
    end

    test "update_device/2 with valid data updates the device" do
      device = device_fixture()
      update_attrs = %{custom_name: "Bedroom"}

      assert {:ok, %Device{} = device} = Cloud.update_device(device, update_attrs)
      assert device.custom_name == "Bedroom"
    end

    test "update_device/2 with invalid data returns error changeset" do
      device = device_fixture()
      invalid_attrs = %{custom_name: ""}

      assert {:error, %Ecto.Changeset{}} = Cloud.update_device(device, invalid_attrs)
      assert device == Cloud.get_device!(device.id)
    end

    test "delete_device/1 deletes the device" do
      device = device_fixture()

      assert {:ok, %Device{}} = Cloud.delete_device(device)
      assert_raise Ecto.NoResultsError, fn -> Cloud.get_device!(device.id) end
    end

    test "change_device/1 returns a device changeset" do
      device = device_fixture()

      assert %Ecto.Changeset{} = Cloud.change_device(device)
    end
  end

  describe "reports" do
    alias Shelly.Schemas.{Device, Report}

    setup [:create_report]

    test "list_reports/0 returns all reports", %{device: device, report: report} do
      assert Cloud.list_reports(device.id) == [report]
    end

    test "list_reports_in_range/3 returns all reports in range", %{device: device, report: report} do
      now = DateTime.utc_now()
      tomorrow = DateTime.add(now, 1, :day)
      yesterday = DateTime.add(now, -1, :day)

      assert Cloud.list_reports_in_range(device.id, yesterday, now) == [report]
      assert Cloud.list_reports_in_range(device.id, now, tomorrow) == []
    end

    test "get_report!/1 returns the report with given id", %{report: report} do
      assert Cloud.get_report!(report.id) == report
    end

    test "get_hourly_report/1 returns hourly report", %{device: device, report: report} do
      hour_ago = DateTime.add(DateTime.utc_now(), -1, :hour)
      report_fixture(%{device_id: device.id, inserted_at: hour_ago, updated_at: hour_ago})

      assert Cloud.get_hourly_report(device.name) == report
    end

    test "delete_report/1 deletes the report", %{report: report} do
      assert {:ok, %Report{}} = Cloud.delete_report(report)
      assert_raise Ecto.NoResultsError, fn -> Cloud.get_report!(report.id) end
    end

    test "insert_hourly_report/2 should create and update unregistered device" do
      device_name = "shellyplug-s-A72538"

      assert {:ok,
              %{
                device: %Device{name: ^device_name, total: 100, last_reported: 100},
                report: %Report{total: 100}
              }} =
               Cloud.insert_hourly_report(100, device_name)

      assert {:ok,
              %{
                device: %Device{name: ^device_name, total: 150, last_reported: 50},
                report: %Report{total: 150}
              }} =
               Cloud.insert_hourly_report(50, device_name)
    end

    test "insert_hourly_report/2 should update registered device", %{device: device} do
      device_name = device.name

      assert {:ok,
              %{
                device: %Device{name: ^device_name, total: 150, last_reported: 150},
                report: %Report{total: 150}
              }} =
               Cloud.insert_hourly_report(150, device_name)

      assert {:ok,
              %{
                device: %Device{name: ^device_name, total: 200, last_reported: 200},
                report: %Report{total: 200}
              }} =
               Cloud.insert_hourly_report(200, device_name)
    end
  end

  def create_report(_) do
    device = device_fixture()
    report = report_fixture(%{device_id: device.id})
    %{device: device, report: report}
  end
end
