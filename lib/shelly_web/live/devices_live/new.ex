defmodule ShellyWeb.DevicesLive.New do
  use ShellyWeb, :live_view

  alias Shelly.Cloud
  alias Shelly.Schemas.Device

  def mount(_params, _session, socket) do
    {:ok, create_form(socket)}
  end

  def handle_event("validate", %{"device" => device_params}, socket) do
    form =
      %Device{}
      |> Device.create_changeset(device_params)
      |> Map.put(:action, :update)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"device" => device_params}, socket) do
    case Cloud.create_device(device_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Device created")
         |> push_navigate(to: ~p"/devices")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp create_form(socket) do
    assign(socket, form: to_form(Device.create_changeset(%Device{}, %{})))
  end
end
