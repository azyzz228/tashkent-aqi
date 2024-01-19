defmodule TashkentAqNotifier.SubscribersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TashkentAqNotifier.Subscribers` context.
  """

  @doc """
  Generate a subscriber.
  """
  def subscriber_fixture(attrs \\ %{}) do
    {:ok, subscriber} =
      attrs
      |> Enum.into(%{
        chat_id: 42,
        first_name: "some first_name",
        id: 42,
        is_bot: true,
        language_code: "some language_code",
        username: "some username"
      })
      |> TashkentAqNotifier.Subscribers.create_subscriber()

    subscriber
  end
end
