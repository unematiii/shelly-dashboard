defmodule Shelly.CloudFixtures do
  alias Shelly.Repo
  alias Shelly.Schemas.{Device, Report}

  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shelly.Cloud` context.
  """

  @doc """
  Generate a device.
  """
  def device_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        name: "shellyplug-s-A71714",
        custom_name: "Livingroom"
      })
      |> Map.put_new(:total, 0)
      |> Map.put_new(:last_reported, 0)

    {:ok, device} =
      %Device{}
      |> Device.changeset(attrs)
      |> Repo.insert()

    device
  end

  @doc """
  Generate a report.
  """
  def report_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Map.put_new(:total, 0)

    {:ok, report} =
      %Report{}
      |> Report.changeset(attrs)
      |> Repo.insert()

    report
  end
end
