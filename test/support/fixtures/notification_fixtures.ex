defmodule TashkentAqNotifier.NotificationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TashkentAqNotifier.Notification` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        received_count: 42,
        recepient_count: 42,
        text: "some text"
      })
      |> TashkentAqNotifier.Notification.create_message()

    message
  end
end
