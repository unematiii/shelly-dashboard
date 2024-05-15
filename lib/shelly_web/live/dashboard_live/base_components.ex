defmodule ShellyWeb.DashboardLive.BaseComponents do
  use ShellyWeb, :html

  alias Shelly.Stats

  attr :target, :string, required: true

  def filters_drawer_trigger(assigns) do
    ~H"""
    <button
      type="button"
      data-drawer-target={@target}
      data-drawer-show={@target}
      data-drawer-placement="right"
      data-drawer-backdrop="false"
      aria-controls={@target}
      class={[
        "flex items-center justify-center text-white rounded-full fixed end-6 bottom-6 group w-14 h-14 focus:outline-none",
        "bg-blue-700 hover:bg-blue-800 focus:ring-4 focus:ring-blue-300",
        "dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
      ]}
    >
      <.icon name="hero-adjustments-horizontal" class="w-6 h-6" />
      <span class="sr-only">Show filters</span>
    </button>
    """
  end

  attr :name, :string, required: true
  slot :inner_block, required: true

  def filters_drawer(assigns) do
    ~H"""
    <div
      id={@name}
      class="fixed top-0 right-0 z-40 pt-20 h-screen p-4 overflow-y-auto transition-transform translate-x-full bg-white w-96 dark:bg-gray-800 border-l border-gray-200 dark:border-gray-700"
      tabindex="-1"
      aria-labelledby="drawer-right-label"
    >
      <h5
        id="drawer-right-label"
        class="inline-flex items-center mb-4 gap-4 text-gray-900 rounded-lg dark:text-white"
      >
        <.icon name="hero-adjustments-horizontal" class="w-5 h-5" />Adjust filters
      </h5>

      <button
        type="button"
        data-drawer-hide={@name}
        aria-controls={@name}
        class="text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 absolute top-20 end-2.5 inline-flex items-center justify-center dark:hover:bg-gray-600 dark:hover:text-white"
      >
        <.icon name="hero-x-mark-solid" class="h-5 w-5" />
        <span class="sr-only">Close menu</span>
      </button>

      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :reports, :list, required: true

  def consumption_chart(assigns) do
    reports = Map.get(assigns, :reports, [])

    series =
      reports
      |> Map.to_list()
      |> Enum.map(fn {name, reports} ->
        %{
          name: name,
          type: "line",
          data:
            Enum.map(reports, fn %{:total => total, :inserted_at => date} ->
              %{
                y: format_total(total),
                x: datetime_to_timestamp(date)
              }
            end)
        }
      end)
      |> encode_series()

    total =
      reports
      |> Map.values()
      |> Enum.reduce(0, fn reports, total ->
        total + (Enum.map(reports, & &1.total) |> Enum.sum())
      end)

    assigns =
      assigns
      |> assign(:series, series)
      |> assign(:total, total)

    ~H"""
    <div class="w-full bg-white rounded-lg shadow dark:bg-gray-800 p-4 md:p-6">
      <div class="flex justify-between mb-5">
        <div>
          <h5 class="leading-none text-3xl font-bold text-gray-900 dark:text-white pb-2">
            <%= format_total(@total) %> kWh
          </h5>
          <p class="text-base font-normal text-gray-500 dark:text-gray-400">
            Total power consumption
          </p>
        </div>
      </div>

      <.chart
        :if={@total != 0}
        id="total-consumption-chart"
        data-series={@series}
        data-legend-show="true"
        data-x-axis-type="datetime"
        data-y-axis-labels-format="(&1) kWh"
      />

      <.alert :if={@total == 0} variant="info">
        No data for selected period
      </.alert>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :prices, :list, required: true
  attr :reports, :list, required: true

  def device_price_chart(assigns) do
    name = Map.get(assigns, :name, "")
    reports = Map.get(assigns, :reports, [])
    prices = Map.get(assigns, :prices, [])

    stats = Stats.get_price_breakdown(prices, reports)

    series =
      [
        %{
          name: name,
          type: "line",
          data:
            Enum.map(stats, fn %{report: %{:inserted_at => date}, total: total} ->
              %{
                y: format_price(total),
                x: datetime_to_timestamp(date)
              }
            end)
        }
      ]
      |> encode_series()

    total = stats |> Enum.reduce(0, fn %{total: total}, acc -> acc + total end)

    assigns =
      assigns
      |> assign(:id, "#{name}-price-chart")
      |> assign(:series, series)
      |> assign(:total, total)

    ~H"""
    <div class="w-full bg-white rounded-lg shadow dark:bg-gray-800 p-4 md:p-6">
      <div class="flex justify-between mb-5">
        <div>
          <h5 class="leading-none text-3xl font-bold text-gray-900 dark:text-white pb-2">
            <%= format_price(@total, 2) %>€
          </h5>
          <p class="text-base font-normal text-gray-500 dark:text-gray-400">
            Total fee for <%= @name %>
          </p>
        </div>
      </div>

      <.chart
        :if={@total != 0}
        id={@id}
        data-series={@series}
        data-legend-show="true"
        data-x-axis-type="datetime"
        data-y-axis-labels-format="(&1)€"
      />

      <.alert :if={@total == 0} variant="info">
        No data for selected period
      </.alert>
    </div>
    """
  end

  attr :status, :string, default: "Loading..."

  def skeleton(assigns) do
    ~H"""
    <div
      role="status"
      class="max-w p-4 mb-4 rounded-lg shadow animate-pulse md:p-6 dark:border-gray-700"
    >
      <div class="h-6 bg-gray-200 rounded-full dark:bg-gray-700 w-32 mb-2"></div>
      <div class="w-48 h-4 mb-10 bg-gray-200 rounded-full dark:bg-gray-700"></div>
      <div class="h-2 bg-gray-200 rounded-full dark:bg-gray-700 mb-2.5"></div>
      <div class="h-2 bg-gray-200 rounded-full dark:bg-gray-700 mb-2.5"></div>
      <div class="h-2 bg-gray-200 rounded-full dark:bg-gray-700 mb-5"></div>
      <span class="sr-only">{@status}</span>
    </div>
    """
  end

  defp datetime_to_timestamp(date) do
    DateTime.to_unix(date, :milliseconds)
  end

  defp encode_series(series) do
    case Jason.encode(series, escape: :html_safe) do
      {:ok, series} -> series
      _ -> "[]"
    end
  end

  defp format_price(price, precision \\ 4)

  defp format_price(price, precision) when is_float(price) do
    Float.ceil(price, precision)
  end

  defp format_price(price, _precision) when is_integer(price) do
    price
  end

  defp format_total(total) do
    Stats.convert(total, :wm, :kwh) |> Float.ceil(4)
  end
end
