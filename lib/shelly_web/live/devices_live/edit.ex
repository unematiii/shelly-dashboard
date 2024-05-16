defmodule ShellyWeb.DevicesLive.Edit do
  use ShellyWeb, :live_view

  alias Shelly.Cloud
  alias Shelly.Schemas.Device

  def mount(%{"id" => device_id}, _session, socket) do
    device = Cloud.get_device!(device_id)

    socket =
      socket
      |> create_form(device)
      |> set_device(device)

    Cloud.subscribe_to_device(device_id)

    {:ok, socket}
  end

  def handle_event("validate", %{"device" => device_params}, socket) do
    form =
      socket.assigns.device
      |> Device.update_changeset(device_params)
      |> Map.put(:action, :update)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"device" => device_params}, socket) do
    case Cloud.update_device(socket.assigns.device, device_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Device updated")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_info({:device, device}, socket) do
    socket =
      socket
      |> create_form(device)
      |> set_device(device)

    {:noreply, socket}
  end

  defp create_form(socket, device) do
    assign(socket, form: to_form(Device.update_changeset(device, %{})))
  end

  defp set_device(socket, device) do
    assign(socket, device: device)
  end
end
