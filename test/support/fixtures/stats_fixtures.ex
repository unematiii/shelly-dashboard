defmodule Shelly.StatsFixtures do
  def today(), do: Date.utc_today()
  def yesterday(), do: Date.add(today(), -1)
  def tomorrow(), do: Date.add(today(), 1)
  def first_day_of_month(), do: Date.beginning_of_month(today())
  def last_day_of_month(), do: Date.end_of_month(today())

  def start_of_day(), do: Time.new!(12, 0, 0)
  def end_of_day(), do: Time.new!(0, 0, 0)

  def price_fixture(attrs \\ %{}) do
    {:ok, price} =
      attrs
      |> Shelly.Stats.insert_price()

    price
  end

  def fixed_price_fixture(start_date \\ first_day_of_month(), end_date \\ last_day_of_month()) do
    price_fixture(%{
      name: "Fixed fee",
      type: :fixed,
      amount: 5,
      start_date: start_date,
      end_date: end_date
    })
  end

  def monthly_price_fixture(start_date \\ first_day_of_month(), end_date \\ last_day_of_month()) do
    price_fixture(%{
      name: "Monthly fee",
      type: :monthly,
      amount: 2,
      start_date: start_date,
      end_date: end_date
    })
  end

  def vat_price_fixture(start_date \\ first_day_of_month(), end_date \\ last_day_of_month()) do
    price_fixture(%{
      name: "VAT",
      type: :vat,
      amount: 22,
      start_date: start_date,
      end_date: end_date
    })
  end
end
