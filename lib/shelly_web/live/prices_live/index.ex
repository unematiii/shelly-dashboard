defmodule ShellyWeb.PricesLive.Index do
  use ShellyWeb, :live_view

  alias Shelly.Schemas.Price
  alias Shelly.Stats

  def mount(_params, _session, socket) do
    {:ok, get_prices(socket)}
  end

  def handle_event("delete_price", %{"price-id" => price_id}, socket) do
    {[price], prices} =
      socket.assigns.prices
      |> Enum.split_with(&(&1.id == String.to_integer(price_id)))

    Stats.delete_price(price)

    socket =
      socket
      |> set_prices(prices)
      |> put_flash(:info, "Pricing info deleted")

    {:noreply, socket}
  end

  defp get_prices(socket) do
    prices =
      Stats.list_prices()
      |> format_prices

    set_prices(socket, prices)
  end

  defp format_prices(prices) do
    Enum.map(prices, &format_price/1)
  end

  defp format_price(price) do
    price
    |> format_amount
    |> format_timestamp
  end

  defp format_amount(%Price{amount: amount, type: type} = price) do
    amount =
      case type do
        :vat -> "#{amount}%"
        :monthly -> "#{amount}€"
        _ -> "#{amount}€ / kWh"
      end

    %{price | amount: amount}
  end

  defp format_timestamp(%Price{inserted_at: inserted_at} = price) do
    %{price | inserted_at: Calendar.strftime(inserted_at, "%d/%m/%Y %I:%M:%S %p")}
  end

  defp set_prices(socket, prices) do
    assign(socket, prices: prices)
  end
end
