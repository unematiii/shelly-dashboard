defmodule Shelly.CloudFixtures do
  alias Shelly.Repo
  alias Shelly.Schemas.Report

  @moduledoc """
  This module defines test helpers for creating
  entities via the `Shelly.Cloud` context.
  """

  @doc """
  Generate a device.
  """
  def device_fixture(attrs \\ %{}) do
    {:ok, device} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Shelly.Cloud.create_device()

    device
  end

  @doc """
  Generate a report.
  """
  def report_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        total: 42
      })

    {:ok, report} =
      %Report{}
      |> Report.changeset(attrs)
      |> Repo.insert()

    report
  end
end
