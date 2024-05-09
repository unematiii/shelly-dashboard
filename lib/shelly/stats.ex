defmodule Shelly.Stats do
  import Ecto.Query, warn: false

  alias Shelly.Schemas.{Price, Report}
  alias Shelly.Repo

  def delete_price(%Price{} = price) do
    Repo.delete(price)
  end

  @spec get_price(number()) :: Price.t() | nil
  def get_price(id), do: Repo.get(Price, id)

  def get_price!(id), do: Repo.get!(Price, id)

  def insert_price(attrs \\ %{}) do
    %Price{}
    |> Price.changeset(attrs)
    |> Repo.insert()
  end

  def list_prices do
    Price
    |> order_by(asc: :id)
    |> Repo.all()
  end

  def list_prices_in_range(start_time, end_time) do
    Price
    |> Price.in_range(start_time, end_time)
    |> Repo.all()
  end

  def update_price(%Price{} = price, attrs) do
    price
    |> Price.changeset(attrs)
    |> Repo.update()
  end

  @spec convert(number(), :wm, :kwh) :: float()
  def convert(value, :wm, :kwh) do
    value / 60000
  end

  @spec get_price_breakdown(list(Price.t()), list(Report.t())) ::
          list(%{report: Report.t(), total: number()})

  def get_price_breakdown(prices, reports) do
    per_report_prices =
      prices
      |> Enum.filter(&Enum.member?([:fixed, :hourly], &1.type))

    vat = Enum.find(prices, &(&1.type == :vat))

    reports
    |> Enum.sort_by(& &1.updated_at, {:asc, DateTime})
    |> Enum.map(&%{report: &1, total: 0})
    |> apply_prices(per_report_prices)
    |> apply_vat(vat)
  end

  @spec apply_prices(list(%{report: Report.t(), total: number()}), list(Price.t())) ::
          list(%{report: Report.t(), total: number()})

  defp apply_prices(components, prices) do
    Enum.map(components, fn component = %{report: report} ->
      %{
        component
        | total:
            prices
            |> Enum.reduce(component.total, fn price, total ->
              cond do
                price_applies_to?(price, report) -> total + price_for_kwh(price, report.total)
                true -> total
              end
            end)
      }
    end)
  end

  @spec apply_vat(list(%{report: Report.t(), total: number()}), Price.t() | nil) ::
          list(%{report: Report.t(), total: number()})

  defp apply_vat(components, vat) do
    case vat do
      price = %Price{type: :vat} ->
        components
        |> Enum.map(fn %{report: report, total: total} ->
          %{
            report: report,
            total:
              cond do
                price_applies_to?(price, report) -> total + price_for_vat(price, total)
                true -> total
              end
          }
        end)

      _ ->
        components
    end
  end

  defp is_in_range?(%Date{} = start_date, %Date{} = end_date, %DateTime{} = subject) do
    Date.range(start_date, end_date)
    |> Enum.member?(DateTime.to_date(subject))
  end

  defp is_in_range?(%Time{} = start_time, %Time{} = end_time, %DateTime{} = subject) do
    Time.compare(subject, start_time) != :lt and Time.compare(end_time, subject) == :gt
  end

  defp price_applies_to?(
         %Price{
           type: :hourly,
           start_date: start_date,
           end_date: end_date,
           hour_interval_start: hour_interval_start = %Time{},
           hour_interval_end: hour_interval_end = %Time{}
         },
         %Report{updated_at: updated_at}
       ) do
    [{start_date, end_date, updated_at}, {hour_interval_start, hour_interval_end, updated_at}]
    |> Enum.all?(fn {a, b, s} -> is_in_range?(a, b, s) end)
  end

  defp price_applies_to?(
         %Price{start_date: start_date, end_date: end_date},
         %Report{updated_at: updated_at}
       ) do
    is_in_range?(start_date, end_date, updated_at)
  end

  defp price_for_kwh(%Price{amount: amount}, total) do
    amount * convert(total, :wm, :kwh)
  end

  defp price_for_vat(%Price{type: :vat, amount: amount}, total) do
    amount * (total / 100)
  end
end
