defmodule ShellyWeb.DevicesLive.Index do
  use ShellyWeb, :live_view

  alias Shelly.Cloud
  alias Shelly.Schemas.Device
  alias Shelly.Stats

  def mount(_params, _session, socket) do
    {:ok, get_devices(socket)}
  end

  def handle_event("delete_device", %{"device-id" => device_id}, socket) do
    {[device], devices} =
      socket.assigns.devices
      |> Enum.split_with(&(&1.id == String.to_integer(device_id)))

    Cloud.delete_device(device)
    Cloud.unsubscribe_from_device(device.id)

    socket =
      socket
      |> set_devices(devices)
      |> put_flash(:info, "Device deleted")

    {:noreply, socket}
  end

  def handle_info({:device, device}, socket) do
    devices =
      socket.assigns.devices
      |> Enum.map(fn d -> if d.id === device.id, do: format_device(device), else: d end)

    {:noreply, set_devices(socket, devices)}
  end

  defp get_devices(socket) do
    devices =
      Cloud.list_devices()
      |> format_devices

    Enum.each(devices, &Cloud.subscribe_to_device(&1.id))

    set_devices(socket, devices)
  end

  defp format_devices(devices) do
    Enum.map(devices, &format_device/1)
  end

  defp format_device(device) do
    device
    |> format_timestamp
    |> format_total
  end

  defp format_timestamp(%Device{updated_at: updated_at} = device) do
    %{device | updated_at: Calendar.strftime(updated_at, "%d/%m/%Y %I:%M:%S %p")}
  end

  defp format_total(%Device{total: total} = device) do
    total =
      total
      |> Stats.convert(:wm, :kwh)
      |> Float.ceil(4)

    %{device | total: total}
  end

  defp set_devices(socket, devices) do
    assign(socket, devices: devices)
  end
end
