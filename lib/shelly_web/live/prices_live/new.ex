defmodule ShellyWeb.PricesLive.New do
  use ShellyWeb, :live_view

  alias Shelly.Schemas.Price
  alias Shelly.Stats
  alias ShellyWeb.PricesLive.Components.PriceForm

  def mount(_params, _session, socket) do
    socket =
      socket
      |> create_changeset()
      |> set_price()

    {:ok, socket}
  end

  def handle_event("validate", %{"price" => price_params}, socket) do
    changeset =
      %Price{}
      |> Price.changeset(price_params)
      |> Map.put(:action, :insert)

    {:noreply, set_changeset(socket, changeset)}
  end

  def handle_event("save", %{"price" => price_params}, socket) do
    case Stats.insert_price(price_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pricing info inserted")
         |> push_navigate(to: ~p"/pricing")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, set_changeset(socket, changeset)}
    end
  end

  defp create_changeset(socket) do
    set_changeset(socket, Price.changeset(%Price{}, %{"type" => "hourly"}))
  end

  defp set_changeset(socket, changeset) do
    assign(socket, changeset: changeset)
  end

  defp set_price(socket) do
    assign(socket, price: %Price{})
  end
end
