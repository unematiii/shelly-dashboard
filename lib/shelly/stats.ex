defmodule Shelly.Stats do
  import Ecto.Query, warn: false

  alias Shelly.Schemas.Price
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

  def update_price(%Price{} = price, attrs) do
    price
    |> Price.changeset(attrs)
    |> Repo.update()
  end

  @spec convert(number(), :wm, :kwh) :: float()
  def convert(value, :wm, :kwh) do
    value / 60000
  end
end
