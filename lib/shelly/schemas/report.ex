defmodule Shelly.Schemas.Report do
  use Ecto.Schema

  import Ecto.Query, only: [from: 2]
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: Integer.t(),
          device_id: Integer.t(),
          total: Integer.t()
        }

  schema "reports" do
    field(:total, :integer)
    belongs_to(:device, Shelly.Schemas.Device)

    timestamps(type: :utc_datetime)
  end

  @spec changeset(any, map) :: Ecto.Changeset.t()
  def changeset(report, attrs) do
    report
    |> cast(attrs, [:device_id, :total])
    |> validate_required([:device_id, :total])
  end

  def for_current_hour(query) do
    from(r in query,
      where: fragment("? >= date_trunc('hour', current_timestamp)", r.inserted_at),
      where:
        fragment("? < date_trunc('hour', current_timestamp) + interval '1 hour'", r.inserted_at)
    )
  end

  def with_device(query, device_id) do
    from(r in query,
      join: d in Shelly.Schemas.Device,
      on: r.device_id ==  d.id,
      where: d.id == ^device_id
    )
  end

  def with_device_name(query, device_name) do
    from(r in query,
      join: d in Shelly.Schemas.Device,
      on: r.device_id == d.id,
      where: d.name == ^device_name
    )
  end
end
