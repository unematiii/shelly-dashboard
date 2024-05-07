defmodule Shelly.CloudTest do
  use Shelly.DataCase

  alias Shelly.Cloud

  import Shelly.CloudFixtures

  describe "devices" do
    alias Shelly.Schemas.Device

    @invalid_attrs %{name: nil}

    test "list_devices/0 returns all devices" do
      device = device_fixture()
      assert Cloud.list_devices() == [device]
    end

    test "get_device!/1 returns the device with given id" do
      device = device_fixture()
      assert Cloud.get_device!(device.id) == device
    end

    test "create_device/1 with valid data creates a device" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Device{} = device} = Cloud.create_device(valid_attrs)
      assert device.name == "some name"
    end

    test "create_device/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cloud.create_device(@invalid_attrs)
    end

    test "update_device/2 with valid data updates the device" do
      device = device_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Device{} = device} = Cloud.update_device(device, update_attrs)
      assert device.name == "some updated name"
    end

    test "update_device/2 with invalid data returns error changeset" do
      device = device_fixture()
      assert {:error, %Ecto.Changeset{}} = Cloud.update_device(device, @invalid_attrs)
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
    alias Shelly.Schemas.Report

    setup [:create_report]

    test "list_reports/0 returns all reports", %{device: device, report: report} do
      assert Cloud.list_reports(device.id) == [report]
    end

    test "get_report!/1 returns the report with given id", %{report: report} do
      assert Cloud.get_report!(report.id) == report
    end

    test "delete_report/1 deletes the report", %{report: report} do
      assert {:ok, %Report{}} = Cloud.delete_report(report)
      assert_raise Ecto.NoResultsError, fn -> Cloud.get_report!(report.id) end
    end
  end

  def create_report(_) do
    device = device_fixture()
    report = report_fixture(%{device_id: device.id})
    %{device: device, report: report}
  end
end
