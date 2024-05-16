defmodule ShellyWeb.DevicesLive.EditTest do
  use ShellyWeb.ConnCase, async: true

  alias Shelly.Cloud

  import Shelly.CloudFixtures

  describe "edit" do
    setup [:create_device]

    test "disconnected and connected mount", %{
      conn: conn,
      device: device
    } do
      conn = get(conn, "/devices/#{device.id}")
      assert html_response(conn, 200) =~ device.name

      {:ok, view, _html} = live(conn)

      assert view |> element("input[name='device[custom_name]']") |> render() =~
               "#{device.custom_name}"
    end

    test "validates form", %{
      conn: conn,
      device: device
    } do
      {:ok, view, _html} = live(conn, "/devices/#{device.id}")

      view |> form("form") |> render_change(%{device: %{custom_name: ""}}) =~ "can't be blank"
    end

    test "renders error on submit", %{
      conn: conn,
      device: device
    } do
      {:ok, view, _html} = live(conn, "/devices/#{device.id}")

      view |> form("form", %{device: %{custom_name: ""}}) |> render_submit() =~ "can't be blank"
    end

    test "updates device", %{
      conn: conn,
      device: device
    } do
      {:ok, view, _html} = live(conn, "/devices/#{device.id}")

      view |> form("form", %{device: %{custom_name: "Some other name"}}) |> render_submit() =~
        "Device updated"
    end

    test "renders device updates from subscription", %{
      conn: conn,
      device: device
    } do
      {:ok, view, _html} = live(conn, "/devices/#{device.id}")

      assert view |> element("input[name='device[custom_name]']") |> render() =~
               "#{device.custom_name}"

      Cloud.broadcast_device(Map.put(device, :custom_name, "Other name"))

      assert view |> element("input[name='device[custom_name]']") |> render() =~
               "Other name"
    end

    test "navigates to index", %{
      conn: conn,
      device: device
    } do
      {:ok, view, _html} = live(conn, "/devices/#{device.id}")

      view |> element("header a", "Back") |> render_click()

      assert_redirect(view, "/devices")
    end

    def create_device(_) do
      %{device: device_fixture(%{total: 60000})}
    end
  end
end
