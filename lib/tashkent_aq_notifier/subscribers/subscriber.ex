defmodule TashkentAqNotifier.Subscribers.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscribers" do
    field :username, :string
    field :first_name, :string
    field :is_bot, :boolean, default: false
    field :language_code, :string
    field :chat_id, :integer
    field :is_subscribed, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:first_name, :is_bot, :language_code, :username, :chat_id])
    |> validate_required([:first_name, :is_bot, :language_code, :username, :chat_id])
  end
end
