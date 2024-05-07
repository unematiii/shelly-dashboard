defmodule Shelly.Repo.Migrations.CreateReports do
  use Ecto.Migration

  def change do
    create table(:reports) do
      add :total, :integer
      add :device_id, references(:devices, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
