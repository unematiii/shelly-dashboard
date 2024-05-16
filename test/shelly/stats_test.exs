defmodule Shelly.StatsTest do
  use Shelly.DataCase

  import Shelly.StatsFixtures

  alias Shelly.Stats
  alias Shelly.Schemas.{Price, Report}

  describe "stats" do
    test "delete_price/1 deletes the price" do
      price = vat_price_fixture()

      assert {:ok, %Price{}} = Stats.delete_price(price)
      assert_raise Ecto.NoResultsError, fn -> Stats.get_price!(price.id) end
    end

    test "get_price/1 returns the price with given id" do
      price = vat_price_fixture()

      assert Stats.get_price(price.id) == price
    end

    test "insert_price/1 with valid data creates a price" do
      valid_attrs = %{
        name: "Monthly fee",
        type: :monthly,
        amount: 2,
        start_date: first_day_of_month(),
        end_date: last_day_of_month()
      }

      assert {:ok, %Price{} = price} = Stats.insert_price(valid_attrs)
      assert price.name == valid_attrs.name
    end

    test "insert_price/1 with valid data creates a price (hourly)" do
      valid_attrs = %{
        name: "Hourly fee",
        type: :hourly,
        amount: 2,
        start_date: first_day_of_month(),
        end_date: last_day_of_month(),
        hour_interval_start: start_of_day(),
        hour_interval_end: end_of_day()
      }

      assert {:ok, %Price{} = price} = Stats.insert_price(valid_attrs)
      assert price.name == valid_attrs.name
    end

    test "insert_price/1 with invalid data returns error changeset" do
      invalid_attrs = %{
        name: "Hourly fee",
        type: :fixed,
        amount: 2,
        start_date: last_day_of_month(),
        end_date: first_day_of_month()
      }

      assert {:error, %Ecto.Changeset{}} = Stats.insert_price(invalid_attrs)
    end

    test "list_prices/0 returns all prices" do
      price = vat_price_fixture()

      assert Stats.list_prices() == [price]
    end

    test "list_prices/0 returns all prices in range" do
      [_, priceA, priceB] =
        [
          {Date.add(today(), -2), Date.add(today(), -1)},
          {today(), Date.add(today(), 1)},
          {first_day_of_month(), last_day_of_month()}
        ]
        |> Enum.map(fn {start_date, end_date} ->
          price_fixture(%{
            name: "Price",
            amount: 1,
            start_date: start_date,
            end_date: end_date,
            type: :fixed
          })
        end)

      assert Stats.list_prices_in_range(today(), Date.add(today(), 1)) == [priceA, priceB]
    end

    test "update_price/2 with valid data updates the price" do
      price = vat_price_fixture()
      update_attrs = %{name: "VAT (new)"}

      assert {:ok, %Price{} = price} = Stats.update_price(price, update_attrs)
      assert price.name == update_attrs.name
    end

    test "update_price/2 with invalid data returns error changeset" do
      price = vat_price_fixture()
      invalid_attrs = %{amount: -2}

      assert {:error, %Ecto.Changeset{}} = Stats.update_price(price, invalid_attrs)
      assert price == Stats.get_price!(price.id)
    end

    test "convert/3 converts watt minutes to kWh" do
      assert 2.0 === Stats.convert(2 * 60000, :wm, :kwh)
    end

    test "get_price_breakdown/2 returns price breakdown (without VAT)" do
      priceA = %Price{
        name: "Hourly fee",
        type: :hourly,
        amount: 2,
        start_date: first_day_of_month(),
        end_date: last_day_of_month(),
        hour_interval_start: end_of_day(),
        hour_interval_end: start_of_day()
      }

      priceB = %Price{
        name: "Hourly fee (not applicable)",
        type: :hourly,
        amount: 4,
        start_date: Date.add(today(), -2),
        end_date: Date.add(today(), -1),
        hour_interval_start: start_of_day(),
        hour_interval_end: end_of_day()
      }

      priceC = %Price{
        name: "Fixed fee",
        type: :fixed,
        amount: 1,
        start_date: first_day_of_month(),
        end_date: last_day_of_month()
      }

      reportA = %Report{
        total: 60000,
        updated_at: DateTime.new!(today(), Time.new!(13, 0, 0))
      }

      reportB = %Report{
        total: 60000,
        updated_at: DateTime.new!(today(), Time.new!(01, 0, 0))
      }

      assert [%{report: ^reportB, total: 3.0}, %{report: ^reportA, total: 1.0}] =
               Stats.get_price_breakdown([priceA, priceB, priceC], [reportA, reportB])
    end

    test "get_price_breakdown/2 returns price breakdown with VAT" do
      priceA = %Price{
        name: "Hourly fee",
        type: :hourly,
        amount: 2,
        start_date: first_day_of_month(),
        end_date: last_day_of_month(),
        hour_interval_start: start_of_day(),
        hour_interval_end: end_of_day()
      }

      priceB = %Price{
        name: "VAT",
        type: :vat,
        amount: 20,
        start_date: first_day_of_month(),
        end_date: last_day_of_month()
      }

      reportA = %Report{
        total: 60000,
        updated_at: DateTime.new!(today(), Time.new!(13, 0, 0))
      }

      reportB = %Report{
        total: 60000,
        updated_at:
          today()
          |> DateTime.new!(Time.new!(13, 0, 0))
          |> DateTime.add(-60, :day)
      }

      assert [%{report: ^reportB, total: 0}, %{report: ^reportA, total: 2.4}] =
               Stats.get_price_breakdown([priceA, priceB], [reportA, reportB])
    end

    test "is_in_range/3 checks if subject date is in date range" do
      assert true ==
               Stats.is_in_range?(
                 yesterday(),
                 tomorrow(),
                 DateTime.new!(today(), Time.new!(13, 0, 0))
               )

      assert false ==
               Stats.is_in_range?(
                 today(),
                 tomorrow(),
                 DateTime.new!(yesterday(), Time.new!(13, 0, 0))
               )
    end

    test "is_in_range/3 checks if subject date is in time range" do
      assert true ==
               Stats.is_in_range?(
                 Time.new!(13, 0, 0),
                 Time.new!(18, 0, 0),
                 DateTime.new!(today(), Time.new!(14, 0, 0))
               )

      assert true ==
               Stats.is_in_range?(
                 Time.new!(12, 0, 0),
                 Time.new!(0, 0, 0),
                 DateTime.new!(today(), Time.new!(14, 0, 0))
               )

      assert false ==
               Stats.is_in_range?(
                 Time.new!(11, 0, 0),
                 Time.new!(12, 0, 0),
                 DateTime.new!(today(), Time.new!(14, 0, 0))
               )
    end
  end
end
