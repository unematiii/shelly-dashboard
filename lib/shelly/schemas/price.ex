defmodule Shelly.Schemas.Price do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: Integer.t(),
          name: String.t(),
          type: atom(),
          amount: float(),
          start_date: Date.t(),
          end_date: Date.t(),
          hour_interval_start: Time.t() | nil,
          hour_interval_end: Time.t() | nil
        }

  schema "prices" do
    field(:name, :string)
    field(:type, Ecto.Enum, values: [:hourly, :monthly, :fixed, :vat])
    field(:amount, :float)
    field(:start_date, :date)
    field(:end_date, :date)
    field(:hour_interval_start, :time)
    field(:hour_interval_end, :time)

    timestamps(type: :utc_datetime)
  end

  @spec changeset(Price.t(), map) :: Ecto.Changeset.t()
  def changeset(price, attrs) do
    price
    |> cast(attrs, [:name, :type, :amount, :start_date, :end_date])
    |> validate_required([:name, :type, :amount, :start_date, :end_date])
    |> validate_number(:amount, greater_than: 0)
    |> validate_date_range()
    |> changeset_for_type(attrs)
  end

  @spec changeset_for_type(Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  defp changeset_for_type(changeset, %{"type" => "hourly"} = attrs) do
    changeset
    |> cast(attrs, [:hour_interval_start, :hour_interval_end])
    |> validate_required([:hour_interval_start, :hour_interval_end])
  end

  @spec changeset_for_type(Ecto.Changeset.t(), map) :: Ecto.Changeset.t()
  defp changeset_for_type(changeset, _attrs) do
    changeset
  end

  defp validate_date_range(changeset) do
    validate_date_range(
      changeset,
      get_field(changeset, :start_date),
      get_field(changeset, :end_date)
    )
  end

  defp validate_date_range(changeset, %Date{} = start_date, %Date{} = end_date) do
    case Date.compare(start_date, end_date) do
      :gt -> add_error(changeset, :start_date, "cannot be later than 'end_date'")
      _ -> changeset
    end
  end

  defp validate_date_range(changeset, _start_date, _end_date) do
    changeset
  end
end
