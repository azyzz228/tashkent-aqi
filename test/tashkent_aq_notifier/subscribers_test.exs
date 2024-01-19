defmodule TashkentAqNotifier.SubscribersTest do
  use TashkentAqNotifier.DataCase

  alias TashkentAqNotifier.Subscribers

  describe "subscribers" do
    alias TashkentAqNotifier.Subscribers.Subscriber

    import TashkentAqNotifier.SubscribersFixtures

    @invalid_attrs %{id: nil, username: nil, first_name: nil, is_bot: nil, language_code: nil, chat_id: nil}

    test "list_subscribers/0 returns all subscribers" do
      subscriber = subscriber_fixture()
      assert Subscribers.list_subscribers() == [subscriber]
    end

    test "get_subscriber!/1 returns the subscriber with given id" do
      subscriber = subscriber_fixture()
      assert Subscribers.get_subscriber!(subscriber.id) == subscriber
    end

    test "create_subscriber/1 with valid data creates a subscriber" do
      valid_attrs = %{id: 42, username: "some username", first_name: "some first_name", is_bot: true, language_code: "some language_code", chat_id: 42}

      assert {:ok, %Subscriber{} = subscriber} = Subscribers.create_subscriber(valid_attrs)
      assert subscriber.id == 42
      assert subscriber.username == "some username"
      assert subscriber.first_name == "some first_name"
      assert subscriber.is_bot == true
      assert subscriber.language_code == "some language_code"
      assert subscriber.chat_id == 42
    end

    test "create_subscriber/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subscribers.create_subscriber(@invalid_attrs)
    end

    test "update_subscriber/2 with valid data updates the subscriber" do
      subscriber = subscriber_fixture()
      update_attrs = %{id: 43, username: "some updated username", first_name: "some updated first_name", is_bot: false, language_code: "some updated language_code", chat_id: 43}

      assert {:ok, %Subscriber{} = subscriber} = Subscribers.update_subscriber(subscriber, update_attrs)
      assert subscriber.id == 43
      assert subscriber.username == "some updated username"
      assert subscriber.first_name == "some updated first_name"
      assert subscriber.is_bot == false
      assert subscriber.language_code == "some updated language_code"
      assert subscriber.chat_id == 43
    end

    test "update_subscriber/2 with invalid data returns error changeset" do
      subscriber = subscriber_fixture()
      assert {:error, %Ecto.Changeset{}} = Subscribers.update_subscriber(subscriber, @invalid_attrs)
      assert subscriber == Subscribers.get_subscriber!(subscriber.id)
    end

    test "delete_subscriber/1 deletes the subscriber" do
      subscriber = subscriber_fixture()
      assert {:ok, %Subscriber{}} = Subscribers.delete_subscriber(subscriber)
      assert_raise Ecto.NoResultsError, fn -> Subscribers.get_subscriber!(subscriber.id) end
    end

    test "change_subscriber/1 returns a subscriber changeset" do
      subscriber = subscriber_fixture()
      assert %Ecto.Changeset{} = Subscribers.change_subscriber(subscriber)
    end
  end
end
