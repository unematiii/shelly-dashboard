defmodule ShellyWeb.DashboardLive.FiltersForm do
  use ShellyWeb, :live_component

  import Ecto.Changeset

  @form_fields %{
    start_date: :utc_datetime,
    end_date: :utc_datetime,
    devices: {:array, :string}
  }

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="filters-form"
        phx-change="validate"
        phx-submit="submit"
        phx-target={@myself}
      >
        <div class="flex flex-col gap-3">
          <div class="flex flex-col  gap-x-2">
            <p class="text-sm font-medium text-gray-900 dark:text-white">Start date</p>
            <.input field={@form[:start_date]} type="date-time-picker" class="flex-1" />
          </div>

          <div class="flex flex-col gap-x-2">
            <p class="text-sm font-medium text-gray-900 dark:text-white">End date</p>
            <.input field={@form[:end_date]} type="date-time-picker" class="flex-1" />
          </div>
        </div>

        <div class="flex flex-col gap-x-2">
          <p class="text-sm font-medium text-gray-900 dark:text-white">Devices</p>
          <.input
            field={@form[:devices]}
            class="flex-1"
            type="select"
            options={device_options(@devices)}
            multiple
          />
        </div>

        <:actions>
          <.button>Apply</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(socket) do
    form =
      %{}
      |> changeset()
      |> create_form()

    {:ok, set_form(socket, form)}
  end

  def update(
        %{
          :devices => devices,
          :start_date => start_date,
          :end_date => end_date,
          :selected_devices => selected_devices
        },
        socket
      ) do
    params =
      socket.assigns.form.params
      |> Map.merge(%{"devices" => Enum.map(selected_devices, &Integer.to_string/1)})
      |> Map.merge(%{"start_date" => start_date, "end_date" => end_date})

    form =
      params
      |> changeset()
      |> create_form()

    socket =
      socket
      |> set_devices(devices)
      |> set_form(form)

    {:ok, socket}
  end

  def handle_event("validate", %{"form" => form_params}, socket) do
    form =
      form_params
      |> changeset()
      |> create_form()

    {:noreply, set_form(socket, form)}
  end

  def handle_event("submit", %{"form" => form_params}, socket) do
    chnageset = changeset(form_params)

    if chnageset.valid? do
      send(self(), {:filters_changed, get_filters(chnageset.changes)})
    end

    {:noreply, set_form(socket, create_form(chnageset))}
  end

  @spec create_form(Ecto.Changeset.t()) :: Phoenix.HTML.Form.t()
  defp create_form(chnageset) do
    to_form(chnageset, as: :form)
  end

  @spec changeset(map()) :: Ecto.Changeset.t()
  defp changeset(attrs) do
    fields = Map.keys(@form_fields)

    {%{}, @form_fields}
    |> cast(attrs, fields)
    |> validate_required(fields)
    |> validate_date_range()
    |> Map.put(:action, :validate)
  end

  defp device_options(devices) do
    Enum.map(devices, &{"#{&1.name}", &1.id})
  end

  defp get_filters(changes) do
    Map.merge(selected_device_ids(changes), selected_time_range(changes))
  end

  defp selected_device_ids(%{:devices => devices}) do
    %{selected_devices: Enum.map(devices, &String.to_integer/1)}
  end

  def selected_time_range(%{:start_date => start_date, :end_date => end_date}) do
    %{start_date: start_date, end_date: end_date}
  end

  defp set_form(socket, form) do
    assign(socket, form: form)
  end

  defp set_devices(socket, devices) do
    assign(socket, devices: devices)
  end

  defp validate_date_range(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    case {start_date, end_date} do
      {%DateTime{} = start_date, end_date = %DateTime{}} ->
        if DateTime.compare(
             start_date,
             end_date
           ) == :gt do
          changeset
          |> add_error(:start_date, "cannot be later than 'end_date'")
        else
          changeset
        end

      _ ->
        changeset
    end
  end
end
