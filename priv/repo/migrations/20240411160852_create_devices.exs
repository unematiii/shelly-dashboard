defmodule Shelly.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :name, :string
      add :last_reported, :integer
      add :total, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:devices, [:name])
  end
end
