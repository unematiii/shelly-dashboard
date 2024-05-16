defmodule ShellyWeb.DashboardLive.FiltersFormTest do
  use ShellyWeb.ConnCase, async: true

  alias Shelly.Schemas.Device
  alias ShellyWeb.DashboardLive.FiltersForm

  import LiveIsolatedComponent
  import ShellyWeb.CoreComponents, only: [normalize_datetime: 2]
  import Shelly.StatsFixtures

  describe "filters form" do
    setup [:create_fixtures]

    test "renders form", %{device: device, start_date: start_date, end_date: end_date} do
      {:ok, view, _html} =
        live_isolated_component(FiltersForm, %{
          devices: [device],
          start_date: start_date,
          end_date: end_date,
          selected_devices: [device.id]
        })

      assert view |> element("input[name='form[start_date]']") |> render() =~
               normalize_datetime(start_date, :seconds)

      assert view |> element("input[name='form[end_date]']") |> render() =~
               normalize_datetime(end_date, :seconds)

      assert view
             |> element("select[name='form[devices][]'] > option[selected=selected]")
             |> render() =~
               "#{device.custom_name}"
    end

    test "validates form", %{device: device, start_date: start_date, end_date: end_date} do
      {:ok, view, _html} =
        live_isolated_component(FiltersForm, %{
          devices: [device],
          start_date: start_date,
          end_date: end_date,
          selected_devices: [device.id]
        })

      assert view
             |> form("form")
             |> render_change(%{
               form: %{
                 start_date: normalize_datetime(end_date, :seconds),
                 end_date: normalize_datetime(start_date, :seconds)
               }
             }) =~
               "cannot be later than"
    end

    test "validates form on submit", %{device: device, start_date: start_date, end_date: end_date} do
      {:ok, view, _html} =
        live_isolated_component(FiltersForm, %{
          devices: [device],
          start_date: start_date,
          end_date: end_date,
          selected_devices: [device.id]
        })

      assert view
             |> form("form", %{
               form: %{
                 start_date: normalize_datetime(end_date, :seconds),
                 end_date: normalize_datetime(start_date, :seconds)
               }
             })
             |> render_submit() =~
               "cannot be later than"

      refute_handle_info(
        view,
        {:filters_changed, %{}}
      )
    end

    test "submits form", %{device: device, start_date: start_date, end_date: end_date} do
      {:ok, view, _html} =
        live_isolated_component(FiltersForm, %{
          devices: [device],
          start_date: start_date,
          end_date: end_date,
          selected_devices: [device.id]
        })

      view
      |> form("form")
      |> render_submit()

      device_id = device.id

      assert_handle_info(
        view,
        {:filters_changed,
         %{start_date: ^start_date, end_date: ^end_date, selected_devices: [^device_id]}}
      )
    end

    def create_fixtures(_) do
      %{
        device: %Device{
          id: 1,
          name: "shellyplug-s-A71714",
          custom_name: "Livingroom",
          total: 0,
          last_reported: 0
        },
        start_date: DateTime.new!(today(), start_of_day()),
        end_date: DateTime.new!(tomorrow(), end_of_day())
      }
    end
  end
end
