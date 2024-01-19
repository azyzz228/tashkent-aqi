defmodule TashkentAqNotifier.Subscribers do
  @moduledoc """
  The Subscribers context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias TashkentAqNotifier.Repo

  alias TashkentAqNotifier.Subscribers.Subscriber

  @doc """
  Returns the list of subscribers.

  ## Examples

      iex> list_subscribers()
      [%Subscriber{}, ...]

  """
  def list_subscribers do
    Repo.all(Subscriber)
  end

  def list_active_subscribers do
    query = from s in Subscriber, where: s.is_subscribed == true
    Repo.all(query)
  end

  @doc """
  Gets a single subscriber.

  Raises `Ecto.NoResultsError` if the Subscriber does not exist.

  ## Examples

      iex> get_subscriber!(123)
      %Subscriber{}

      iex> get_subscriber!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscriber!(id), do: Repo.get!(Subscriber, id)

  @doc """
  Creates a subscriber.

  ## Examples

      iex> create_subscriber(%{field: value})
      {:ok, %Subscriber{}}

      iex> create_subscriber(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscriber(attrs \\ %{}) do
    %Subscriber{}
    |> Subscriber.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscriber.

  ## Examples

      iex> update_subscriber(subscriber, %{field: new_value})
      {:ok, %Subscriber{}}

      iex> update_subscriber(subscriber, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscriber(%Subscriber{} = subscriber, attrs) do
    subscriber
    |> Subscriber.changeset(attrs)
    |> Repo.update()
  end

  def update_subscriber_status_to_unsubscribed(chat_id) do
    chat_id_string = chat_id |> Integer.to_string()
    query = from s in Subscriber, where: s.chat_id == ^chat_id_string

    Multi.new()
    |> Multi.one(:subcriber, query)
    |> Multi.update(:set_is_subscribed_to_false, fn %{subcriber: subscriber} ->
      Ecto.Changeset.change(subscriber, is_subscribed: false)
    end)
    |> Repo.transaction()
  end

  def update_subscriber_status_to_subcribed(chat_id) do
    chat_id_string = chat_id |> Integer.to_string()
    query = from s in Subscriber, where: s.chat_id == ^chat_id_string

    Multi.new()
    |> Multi.one(:subcriber, query)
    |> Multi.update(:set_is_subscribed_to_false, fn %{subcriber: subscriber} ->
      Ecto.Changeset.change(subscriber, is_subscribed: true)
    end)
    |> Repo.transaction()
  end

  @doc """
  Deletes a subscriber.

  ## Examples

      iex> delete_subscriber(subscriber)
      {:ok, %Subscriber{}}

      iex> delete_subscriber(subscriber)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscriber(%Subscriber{} = subscriber) do
    Repo.delete(subscriber)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscriber changes.

  ## Examples

      iex> change_subscriber(subscriber)
      %Ecto.Changeset{data: %Subscriber{}}

  """
  def change_subscriber(%Subscriber{} = subscriber, attrs \\ %{}) do
    Subscriber.changeset(subscriber, attrs)
  end
end
