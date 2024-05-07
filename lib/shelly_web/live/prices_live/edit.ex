defmodule ShellyWeb.PricesLive.Edit do
  use ShellyWeb, :live_view

  alias Shelly.Schemas.Price
  alias Shelly.Stats
  alias ShellyWeb.PricesLive.Components.PriceForm

  def mount(%{"id" => price_id}, _session, socket) do
    price = Stats.get_price!(price_id)

    socket =
      socket
      |> create_changeset(price)
      |> set_price(price)

    {:ok, socket}
  end

  def handle_event("validate", %{"price" => price_params}, socket) do
    changeset =
      %Price{}
      |> Price.changeset(price_params)
      |> Map.put(:action, :update)

    {:noreply, set_changeset(socket, changeset)}
  end

  def handle_event("save", %{"price" => price_params}, socket) do
    case Stats.update_price(socket.assigns.price, price_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pricing info updated")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, set_changeset(socket, changeset)}
    end
  end

  defp create_changeset(socket, price) do
    set_changeset(socket, Price.changeset(price, %{}))
  end

  defp set_changeset(socket, changeset) do
    assign(socket, changeset: changeset)
  end

  defp set_price(socket, price) do
    assign(socket, price: price)
  end
end
