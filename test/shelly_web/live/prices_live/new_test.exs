defmodule ShellyWeb.PricesLive.NewTest do
  use ShellyWeb.ConnCase, async: true

  import Shelly.StatsFixtures

  describe "new" do
    test "disconnected and connected mount", %{conn: conn} do
      conn = get(conn, "/pricing/new")
      assert html_response(conn, 200) =~ "Add pricing info"
    end

    test "validates form", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/pricing/new")

      view
      |> form("form")
      |> render_change(%{
        price: %{
          name: "Hourly fee",
          type: :hourly,
          amount: 5,
          start_date: tomorrow(),
          end_date: today(),
          hour_interval_start: start_of_day(),
          hour_interval_end: end_of_day()
        }
      }) =~ "cannot be later than 'end_date'"
    end

    test "renders error on submit", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/pricing/new")

      view
      |> form("form", %{
        price: %{
          name: "Hourly fee",
          type: :hourly,
          amount: 0,
          start_date: today(),
          end_date: tomorrow(),
          hour_interval_start: start_of_day(),
          hour_interval_end: end_of_day()
        }
      })
      |> render_submit() =~ "must be greater than 0"
    end

    test "inserts new price", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/pricing/new")

      view
      |> form("form", %{
        price: %{
          name: "Hourly fee",
          type: :hourly,
          amount: 1.3,
          start_date: today(),
          end_date: tomorrow(),
          hour_interval_start: start_of_day(),
          hour_interval_end: end_of_day()
        }
      })
      |> render_submit()

      flash = assert_redirect(view, "/pricing")
      assert flash["info"] == "Pricing info inserted"
    end

    test "navigates to index", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/pricing/new")

      view |> element("header a", "Back") |> render_click()

      assert_redirect(view, "/pricing")
    end
  end
end
