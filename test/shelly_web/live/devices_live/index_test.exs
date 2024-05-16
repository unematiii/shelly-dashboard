defmodule ShellyWeb.DevicesLive.IndexTest do
  use ShellyWeb.ConnCase, async: true

  alias Shelly.Cloud

  import Shelly.CloudFixtures

  describe "index" do
    setup [:create_device]

    test "disconnected and connected mount", %{
      conn: conn,
      device: device
    } do
      conn = get(conn, "/devices")
      assert html_response(conn, 200) =~ "Registered devices"

      {:ok, view, _html} = live(conn)

      assert view |> element("tbody tr[id=#{device.id}] > td:nth-child(1)") |> render() =~
               device.custom_name

      assert view |> element("tbody tr[id=#{device.id}] > td:nth-child(2)") |> render() =~
               device.name

      assert view |> element("tbody tr[id=#{device.id}] > td:nth-child(3)") |> render() =~
               "1.0"
    end

    test "deletes device", %{
      conn: conn,
      device: device
    } do
      {:ok, view, _html} = live(conn, "/devices")

      assert view |> element("tbody tr[id=#{device.id}] > td:nth-child(1)") |> render() =~
               device.custom_name

      result = render_hook(view, :delete_device, %{"device-id" => "#{device.id}"})

      assert result =~ "Device deleted"
      assert result =~ "No devices have been registered"
    end

    test "renders device updates from subscription", %{
      conn: conn,
      device: device
    } do
      {:ok, view, _html} = live(conn, "/devices")

      assert view |> element("tbody tr[id=#{device.id}] > td:nth-child(1)") |> render() =~
               device.custom_name

      Cloud.broadcast_device(Map.put(device, :custom_name, "Other name"))

      assert view |> element("tbody tr[id=#{device.id}] > td:nth-child(1)") |> render() =~
               "Other name"
    end

    test "navigates to edit view", %{
      conn: conn,
      device: device
    } do
      {:ok, view, _html} = live(conn, "/devices")

      view |> element("a[href='/devices/#{device.id}']") |> render_click()

      assert_redirect(view, "/devices/#{device.id}")
    end

    def create_device(_) do
      %{device: device_fixture(%{total: 60000})}
    end
  end

  describe "no data" do
    test "renders info alert", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/devices")

      assert html =~ "No devices have been registered"
    end
  end
end
