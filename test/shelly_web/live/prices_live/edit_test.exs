defmodule ShellyWeb.PricesLive.EditTest do
  use ShellyWeb.ConnCase, async: true

  import Shelly.StatsFixtures

  describe "edit" do
    setup [:create_price]

    test "disconnected and connected mount", %{
      conn: conn,
      price: price
    } do
      conn = get(conn, "/pricing/#{price.id}")
      assert html_response(conn, 200) =~ "Edit pricing info"

      {:ok, view, _html} = live(conn)

      assert view |> element("input[name='price[name]']") |> render() =~ "#{price.name}"

      assert view |> element("select[name='price[type]'] > option[selected=selected]") |> render() =~
               "#{price.type}"

      assert view |> element("input[name='price[amount]']") |> render() =~ "#{price.amount}"

      assert view |> element("input[name='price[start_date]']") |> render() =~
               "#{price.start_date}"

      assert view |> element("input[name='price[end_date]']") |> render() =~
               "#{price.end_date}"
    end

    test "validates form", %{
      conn: conn,
      price: price
    } do
      {:ok, view, _html} = live(conn, "/pricing/#{price.id}")

      view |> form("form") |> render_change(%{price: %{type: :hourly}}) =~ "can't be blank"
    end

    test "renders error on submit", %{
      conn: conn,
      price: price
    } do
      {:ok, view, _html} = live(conn, "/pricing/#{price.id}")

      view |> form("form", %{price: %{type: :hourly}}) |> render_submit() =~ "can't be blank"
    end

    test "updates price", %{
      conn: conn,
      price: price
    } do
      {:ok, view, _html} = live(conn, "/pricing/#{price.id}")

      assert view |> element("input[name='price[amount]']") |> render() =~ "#{price.amount}"

      view |> form("form", %{price: %{amount: price.amount + 1}}) |> render_submit() =~
        "Pricing info updated"
    end

    test "navigates to index", %{
      conn: conn,
      price: price
    } do
      {:ok, view, _html} = live(conn, "/pricing/#{price.id}")

      view |> element("header a", "Back") |> render_click()

      assert_redirect(view, "/pricing")
    end

    def create_price(_) do
      %{price: vat_price_fixture()}
    end
  end
end
