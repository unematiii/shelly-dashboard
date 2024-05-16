defmodule ShellyWeb.PricesLive.IndexTest do
  use ShellyWeb.ConnCase, async: true

  import Shelly.StatsFixtures

  describe "index" do
    setup [:create_prices]

    test "disconnected and connected mount", %{
      conn: conn,
      prices: %{fixed: fixed, monthly: monthly, vat: vat}
    } do
      conn = get(conn, "/pricing")
      assert html_response(conn, 200) =~ "Pricing info"

      {:ok, view, _html} = live(conn)

      assert view |> element("tr", fixed.name) |> render() =~ "#{fixed.amount}€ / kWh"
      assert view |> element("tr", monthly.name) |> render() =~ "#{monthly.amount}€"
      assert view |> element("tr", vat.name) |> render() =~ "#{vat.amount}%"
    end

    test "deletes price", %{
      conn: conn,
      prices: %{vat: vat}
    } do
      {:ok, view, _html} = live(conn, "/pricing")

      assert view |> element("tr", vat.name) |> render() =~ "#{vat.amount}%"

      result = render_hook(view, :delete_price, %{"price-id" => "#{vat.id}"})

      assert result =~ "#{vat.amount}%" == false
      assert result =~ "Pricing info deleted"
    end

    test "navigates to edit view", %{
      conn: conn,
      prices: %{vat: vat}
    } do
      {:ok, view, _html} = live(conn, "/pricing")

      view |> element("a[href='/pricing/#{vat.id}']") |> render_click()

      assert_redirect(view, "/pricing/#{vat.id}")
    end

    def create_prices(_) do
      fixed = fixed_price_fixture()
      monthly = monthly_price_fixture()
      vat = vat_price_fixture()

      %{prices: %{fixed: fixed, monthly: monthly, vat: vat}}
    end
  end

  describe "no data" do
    test "renders info alert", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/pricing")

      assert html =~ "No pricing info available"
    end
  end
end
