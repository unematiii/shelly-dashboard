defmodule Shelly.Repo.Migrations.AddCustomNameToDevices do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      add_if_not_exists :custom_name, :string, default: "Shelly device"
    end
  end
end
