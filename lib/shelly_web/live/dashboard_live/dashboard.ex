defmodule ShellyWeb.DashboardLive.Dashboard do
  use ShellyWeb, :live_view

  import ShellyWeb.DashboardLive.BaseComponents

  alias Shelly.Cloud
  alias Shelly.Stats
  alias ShellyWeb.DashboardLive.FiltersForm

  embed_templates "components/*"

  def mount(_params, _session, socket) do
    devices = Cloud.list_devices()

    socket =
      socket
      |> set_devices(devices)
      |> set_selected_devices(Enum.map(devices, & &1.id))
      |> set_date_range(default_date_range())
      |> fetch_reports()
      |> fetch_prices()

    {:ok, socket}
  end

  def handle_info({:filters_changed, changes}, socket) do
    socket =
      socket
      |> set_date_range(changes)
      |> set_selected_devices(changes)
      |> fetch_reports()
      |> fetch_prices()

    {:noreply, socket}
  end

  defp default_date_range() do
    start_date = Date.beginning_of_month(Date.utc_today())
    end_date = Date.end_of_month(Date.utc_today())

    start_time = Time.new!(12, 0, 0)
    end_time = Time.new!(0, 0, 0)

    %{
      start_date: DateTime.new!(start_date, start_time),
      end_date: DateTime.new!(end_date, end_time)
    }
  end

  defp fetch_prices(socket) do
    %{
      :start_date => start_date,
      :end_date => end_date
    } = socket.assigns

    prices =
      Stats.list_prices_in_range(DateTime.to_date(start_date), DateTime.to_date(end_date))

    set_prices(
      socket,
      prices
    )
  end

  defp fetch_reports(socket) do
    %{
      :devices => devices,
      :start_date => start_date,
      :end_date => end_date,
      :selected_devices => ids
    } = socket.assigns

    devices =
      devices
      |> Enum.filter(fn device -> Enum.member?(ids, device.id) end)

    reports =
      devices
      |> Enum.reduce(%{}, fn device, acc ->
        Map.put(
          acc,
          device.custom_name,
          Cloud.list_reports_in_range(device.id, start_date, end_date)
        )
      end)

    set_reports(socket, reports)
  end

  defp set_devices(socket, devices) do
    assign(socket, devices: devices)
  end

  defp set_selected_devices(socket, %{:selected_devices => ids}) do
    set_selected_devices(socket, ids)
  end

  defp set_selected_devices(socket, ids) do
    assign(socket, selected_devices: ids)
  end

  defp set_date_range(socket, %{:start_date => start_date, :end_date => end_date}) do
    assign(socket, %{start_date: start_date, end_date: end_date})
  end

  defp set_prices(socket, prices) do
    assign(socket, prices: prices)
  end

  defp set_reports(socket, reports) do
    assign(socket, reports: reports)
  end
end
