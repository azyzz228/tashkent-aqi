defmodule TashkentAqNotifier.NotificationTest do
  use TashkentAqNotifier.DataCase

  alias TashkentAqNotifier.Notification

  describe "messages" do
    alias TashkentAqNotifier.Notification.Message

    import TashkentAqNotifier.NotificationFixtures

    @invalid_attrs %{text: nil, recepient_count: nil, received_count: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Notification.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Notification.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{text: "some text", recepient_count: 42, received_count: 42}

      assert {:ok, %Message{} = message} = Notification.create_message(valid_attrs)
      assert message.text == "some text"
      assert message.recepient_count == 42
      assert message.received_count == 42
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notification.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{text: "some updated text", recepient_count: 43, received_count: 43}

      assert {:ok, %Message{} = message} = Notification.update_message(message, update_attrs)
      assert message.text == "some updated text"
      assert message.recepient_count == 43
      assert message.received_count == 43
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Notification.update_message(message, @invalid_attrs)
      assert message == Notification.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Notification.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Notification.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Notification.change_message(message)
    end
  end
end
