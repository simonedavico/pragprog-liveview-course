defmodule LiveviewStudio.StoresFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LiveviewStudio.Stores` context.
  """

  @doc """
  Generate a store.
  """
  def store_fixture(attrs \\ %{}) do
    {:ok, store} =
      attrs
      |> Enum.into(%{
        city: "some city",
        hours: "some hours",
        name: "some name",
        open: true,
        phone_number: "some phone_number",
        street: "some street",
        zip: "some zip"
      })
      |> LiveviewStudio.Stores.create_store()

    store
  end
end
