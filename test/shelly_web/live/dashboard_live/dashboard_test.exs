defmodule ShellyWeb.DashboardLive.DashboardTest do
  use ShellyWeb.ConnCase, async: true

  import Shelly.CloudFixtures
  import Shelly.StatsFixtures
  import ShellyWeb.CoreComponents, only: [normalize_datetime: 2]

  describe "dashboard" do
    setup [:create_fixtures]

    test "disconnected and connected mount", %{conn: conn, device: device} do
      conn = get(conn, "/")
      html = html_response(conn, 200)

      assert html =~ "Dashboard"
      assert html =~ "Loading reports..."

      {:ok, view, html} = live(conn)

      assert html =~ "Loading reports..."

      html = render_async(view)

      refute html =~ "Loading reports..."
      assert html =~ "Total power consumption"
      assert html =~ "0.5 kWh"
      assert html =~ "Total fee for #{device.custom_name}"
      assert html =~ "2.5€"
    end

    test "filters", %{conn: conn, device: device} do
      {:ok, view, _html} = live(conn, "/")

      render_async(view)

      start_date = DateTime.utc_now() |> DateTime.add(-20, :day) |> normalize_datetime(:seconds)
      end_date = DateTime.utc_now() |> DateTime.add(-10, :day) |> normalize_datetime(:seconds)

      html =
        view
        |> form("form[id=filters-form]", %{
          form: %{
            start_date: start_date,
            end_date: end_date
          }
        })
        |> render_submit()

      html = render_async(view)

      assert html =~ "Total power consumption"
      assert html =~ "0 kWh"
      assert html =~ "Total fee for #{device.custom_name}"
      assert html =~ "0€"
    end
  end

  def create_fixtures(_) do
    device =
      device_fixture(%{
        total: 30000,
        last_reported: 50
      })

    report =
      report_fixture(%{
        device_id: device.id,
        total: 30000
      })

    price = fixed_price_fixture()

    %{device: device, report: report, price: price}
  end
end
