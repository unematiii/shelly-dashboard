defmodule Shelly.Repo.Migrations.CreatePrices do
  use Ecto.Migration

  def change do
    create table(:prices) do
      add :name, :string
      add :type, :string
      add :amount, :float
      add :start_date, :date
      add :end_date, :date
      add :hour_interval_start, :time, null: true
      add :hour_interval_end, :time, null: true

      timestamps(type: :utc_datetime)
    end
  end
end
