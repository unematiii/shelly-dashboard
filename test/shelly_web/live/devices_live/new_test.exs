defmodule ShellyWeb.DevicesLive.NewTest do
  use ShellyWeb.ConnCase, async: true

  import Shelly.CloudFixtures

  describe "new" do
    test "disconnected and connected mount", %{conn: conn} do
      conn = get(conn, "/devices/new")
      assert html_response(conn, 200) =~ "Register new device"

      {:ok, view, _html} = live(conn)

      assert view |> element("input[name='device[custom_name]']") |> render() =~
               ~r/value=\"(.+)\"/
    end

    test "validates form", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/devices/new")

      view |> form("form") |> render_change(%{device: %{name: ""}}) =~ "can't be blank"
    end

    test "renders error on submit", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/devices/new")

      device = device_fixture()

      view
      |> form("form", %{device: %{name: device.name, custom_name: "Custom name"}})
      |> render_submit() =~ "has already been taken"
    end

    test "inserts new device", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/devices/new")

      view
      |> form("form", %{device: %{name: "Shellyplug-s-A71714", custom_name: "Some other name"}})
      |> render_submit()

      flash = assert_redirect(view, "/devices")
      assert flash["info"] == "Device created"
    end
  end
end
