defmodule Shelly.Cloud do
  @moduledoc """
  The Cloud context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Shelly.Repo
  alias Shelly.Schemas.{Device, Report}

  @devices_topic "devices"

  @doc """
  Broadcast device

  ## Examples

      iex> broadcast_device(%Device{})

  """
  @spec broadcast_device(Device.t()) :: :ok | {:error, term()}
  def broadcast_device(device) do
    Phoenix.PubSub.broadcast(Shelly.PubSub, "#{@devices_topic}:#{device.id}", {:device, device})
  end

  @doc """
  Susbcribes to device

  ## Examples

      iex> subscribe_to_device(1)

  """
  @spec subscribe_to_device(integer()) :: :ok | {:error, term()}
  def subscribe_to_device(device_id) do
    Phoenix.PubSub.subscribe(Shelly.PubSub, "#{@devices_topic}:#{device_id}")
  end

  @doc """
  Unsusbcribes from device

  ## Examples

      iex> unsubscribe_from_device(1)

  """
  @spec unsubscribe_from_device(integer()) :: :ok
  def unsubscribe_from_device(device_id) do
    Phoenix.PubSub.unsubscribe(Shelly.PubSub, "#{@devices_topic}:#{device_id}")
  end

  @doc """
  Returns the list of devices.

  ## Examples

      iex> list_devices()
      [%Device{}, ...]

  """
  def list_devices do
    Device
    |> order_by(asc: :id)
    |> Repo.all()
  end

  @doc """
  Gets a single device.

  Raises `Ecto.NoResultsError` if the Device does not exist.

  ## Examples

      iex> get_device!(123)
      %Device{}

      iex> get_device!(456)
      ** (Ecto.NoResultsError)

  """
  def get_device!(id), do: Repo.get!(Device, id)

  @doc """
  Gets a single device by name

  ## Examples

      iex> get_by_name!("shellyplug-s-A71714")
      %Device{}

  """
  @spec get_by_name(String) :: Device.t() | nil
  def get_by_name(device_name) do
    Device
    |> Repo.get_by(name: device_name)
  end

  @doc """
  Creates a device.

  ## Examples

      iex> create_device(%{field: value})
      {:ok, %Device{}}

      iex> create_device(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_device(attrs \\ %{}) do
    %Device{}
    |> Device.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a device.

  ## Examples

      iex> update_device(device, %{field: new_value})
      {:ok, %Device{}}

      iex> update_device(device, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_device(%Device{} = device, attrs) do
    device
    |> Device.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a device.

  ## Examples

      iex> delete_device(device)
      {:ok, %Device{}}

      iex> delete_device(device)
      {:error, %Ecto.Changeset{}}

  """
  def delete_device(%Device{} = device) do
    Repo.delete(device)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking device changes.

  ## Examples

      iex> change_device(device)
      %Ecto.Changeset{data: %Device{}}

  """
  def change_device(%Device{} = device, attrs \\ %{}) do
    Device.changeset(device, attrs)
  end

  @doc """
  Returns the list of reports.

  ## Examples

      iex> list_reports()
      [%Report{}, ...]

  """
  def list_reports(device_id) do
    Report
    |> Report.with_device(device_id)
    |> Repo.all()
  end

  @doc """
  Gets a single report.

  Raises `Ecto.NoResultsError` if the Report does not exist.

  ## Examples

      iex> get_report!(123)
      %Report{}

      iex> get_report!(456)
      ** (Ecto.NoResultsError)

  """
  def get_report!(id), do: Repo.get!(Report, id)

  @doc """
  Gets an hourly report for device.

  ## Examples

      iex> get_hourly_report("shellyplug-s-A71714")
      %Report{}

  """
  @spec get_hourly_report(String) :: Report.t() | nil
  def get_hourly_report(device_name) do
    Report
    |> Report.with_device_name(device_name)
    |> Report.for_current_hour()
    |> Repo.one()
  end

  @doc """
  Deletes a report.

  ## Examples

      iex> delete_report(report)
      {:ok, %Report{}}

      iex> delete_report(report)
      {:error, %Ecto.Changeset{}}

  """
  def delete_report(%Report{} = report) do
    Repo.delete(report)
  end

  @doc """
  Inserts or updates hourly report for device.

  ## Examples

      iex> insert_hourly_report(5000, "shellyplug-s-A71714")
      {:ok, {:device: %Device{}, :report: %Report{}}}

      iex> insert_hourly_report(0, "shellyplug-s-A71714")
      {:error, %Ecto.Changeset{}}

  """
  @spec insert_hourly_report(integer(), String) ::
          {:ok, %{device: Device.t(), report: Report.t()}} | {:error, any()}

  def insert_hourly_report(total, device_name) do
    device = get_by_name(device_name) || %Device{}
    report = get_hourly_report(device_name) || %Report{}
    delta = get_difference(total, device.last_reported)

    [device_total, report_total] =
      [device, report]
      |> Enum.map(&get_total(delta, &1.total))

    Multi.new()
    |> Multi.insert_or_update(
      :device,
      Device.changeset(device, %{
        name: device_name,
        last_reported: total,
        total: device_total
      })
    )
    |> Multi.insert_or_update(:report, fn %{device: device} ->
      Report.changeset(report, %{device_id: device.id, total: report_total})
    end)
    |> Repo.transaction()
  end

  defp get_difference(current, nil), do: get_difference(current, 0)
  defp get_difference(current, last) when current < last, do: current
  defp get_difference(current, last) when current >= last, do: current - last

  defp get_total(delta, nil), do: get_total(delta, 0)
  defp get_total(delta, total) when is_integer(total), do: total + delta
end
