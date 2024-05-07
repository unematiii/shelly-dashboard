defmodule ShellyWeb.PricesLive.Components.PriceForm do
  use ShellyWeb, :live_component

  alias Shelly.Schemas.Price

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} label="Name" />
        <.input
          field={@form[:type]}
          label="Type"
          type="select"
          options={
            Ecto.Enum.mappings(
              Shelly.Schemas.Price,
              :type
            )
          }
        />
        <.input field={@form[:amount]} type="number" label="Amount" />

        <div class="flex flex-row gap-4">
          <.input field={@form[:start_date]} label="Applies from" type="date-picker" class="flex-1" />
          <.input field={@form[:end_date]} label="Applies until" type="date-picker" class="flex-1" />
        </div>

        <div id="time-range" class={["flex flex-row gap-4", !@show_time_range && "hidden"]}>
          <.input
            field={@form[:hour_interval_start]}
            label="Start time"
            type="time-picker"
            step="1"
            class="flex-1"
          />
          <.input
            field={@form[:hour_interval_end]}
            label="End time"
            type="time-picker"
            step="1"
            class="flex-1"
          />
        </div>

        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    changeset = Map.get(assigns, :changeset, %Ecto.Changeset{})
    price = Map.get(assigns, :price, %Price{})

    {:ok, create_form(socket, changeset, price)}
  end

  defp create_form(socket, changeset, price) do
    form =
      changeset
      |> to_form()

    socket
    |> set_form(form)
    |> set_price(price)
  end

  defp set_price(socket, price) do
    socket
    |> assign(price: price)
  end

  defp set_form(socket, form) do
    socket
    |> toggle_time_range(form)
    |> assign(form: form)
  end

  defp toggle_time_range(socket, form) do
    show =
      case form[:type].value do
        :hourly -> true
        _ -> false
      end

    assign(socket, show_time_range: show)
  end
end
