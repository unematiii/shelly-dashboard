defmodule Shelly.Schemas.Device do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          custom_name: String.t(),
          last_reported: integer(),
          total: integer()
        }

  schema "devices" do
    field(:name, :string)
    field(:custom_name, :string)
    field(:last_reported, :integer)
    field(:total, :integer)

    has_many(:reports, Shelly.Schemas.Report)

    timestamps(type: :utc_datetime)
  end

  @spec changeset(any, map) :: Ecto.Changeset.t()
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:name, :custom_name, :last_reported, :total])
    |> dynamic_default(:custom_name, &create_custom_name/0)
    |> validate_required([:name, :total, :last_reported])
    |> unique_constraint(:name)
  end

  @spec create_changeset(any, map) :: Ecto.Changeset.t()
  def create_changeset(device, attrs) do
    device
    |> cast(attrs, [:name, :custom_name])
    |> validate_required([:name])
    |> put_change(:last_reported, 0)
    |> put_change(:total, 0)
    |> update_change(:name, &String.trim/1)
    |> dynamic_default(:custom_name, &create_custom_name/0)
    |> unique_constraint(:name)
  end

  @spec update_changeset(any, map) :: Ecto.Changeset.t()
  def update_changeset(device, attrs) do
    device
    |> cast(attrs, [:custom_name])
    |> validate_required([:custom_name])
    |> unique_constraint(:name)
  end

  @spec dynamic_default(Ecto.Changeset.t(), atom(), fun()) :: Ecto.Changeset.t()
  defp dynamic_default(changeset, key, value_fun) do
    case get_field(changeset, key) do
      nil -> put_change(changeset, key, value_fun.())
      _ -> changeset
    end
  end

  defp create_custom_name() do
    UniqueNamesGenerator.generate([:adjectives, :names])
  end
end
