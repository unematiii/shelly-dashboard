defmodule ShellyWeb.DashboardLive.BaseComponentsTest do
  use ShellyWeb.ConnCase, async: true

  import Phoenix.Component
  import Shelly.StatsFixtures

  alias Shelly.Schemas.{Device, Price, Report}
  alias ShellyWeb.DashboardLive.BaseComponents

  describe "filters_drawer_trigger" do
    test "renders component" do
      assert render_component(&BaseComponents.filters_drawer_trigger/1, target: "element-id") =~
               "Show filters"
    end
  end

  describe "filters_drawer" do
    test "renders component" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <BaseComponents.filters_drawer name="element=id">
          <p>content</p>
        </BaseComponents.filters_drawer>
        """)

      assert html =~ "Adjust filters"
      assert html =~ "<p>content</p>"
    end
  end

  describe "consumption_chart" do
    setup [:create_fixtures]

    test "renders component", %{reports: reports} do
      html =
        render_component(&BaseComponents.consumption_chart/1, reports: reports)

      assert html =~ "Total power consumption"
      assert html =~ "1.5 kWh"
      refute html =~ "No data for selected period"
    end

    test "renders no data", %{device: device} do
      html =
        render_component(&BaseComponents.consumption_chart/1,
          reports: %{"#{device.custom_name}" => []}
        )

      assert html =~ "Total power consumption"
      assert html =~ "0 kWh"
      assert html =~ "No data for selected period"
    end
  end

  describe "device_price_chart" do
    setup [:create_fixtures]

    test "renders component", %{device: device, prices: prices, reports: reports} do
      html =
        render_component(&BaseComponents.device_price_chart/1,
          name: device.custom_name,
          prices: prices,
          reports: reports[device.custom_name]
        )

      assert html =~ "Total fee for #{device.custom_name}"
      assert html =~ "1.5€"
    end

    test "renders no data", %{device: device, prices: prices} do
      html =
        render_component(&BaseComponents.device_price_chart/1,
          name: device.custom_name,
          prices: prices,
          reports: []
        )

      assert html =~ "Total fee for #{device.custom_name}"
      assert html =~ "0€"
      assert html =~ "No data for selected period"
    end
  end

  def create_fixtures(_) do
    device = %Device{
      id: 1,
      custom_name: "Livingroom",
      total: 90000,
      last_reported: 500
    }

    reports = [
      %Report{
        device_id: device.id,
        total: 60000,
        updated_at: DateTime.utc_now(),
        inserted_at: DateTime.utc_now()
      },
      %Report{
        device_id: device.id,
        total: 30000,
        updated_at: DateTime.utc_now(),
        inserted_at: DateTime.utc_now()
      }
    ]

    prices = [
      %Price{
        type: :fixed,
        amount: 1,
        start_date: yesterday(),
        end_date: tomorrow()
      }
    ]

    %{device: device, prices: prices, reports: %{"#{device.custom_name}" => reports}}
  end
end
