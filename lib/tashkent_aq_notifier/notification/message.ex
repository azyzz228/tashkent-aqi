defmodule TashkentAqNotifier.Notification.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :text, :string
    field :recepient_count, :integer
    field :received_count, :integer

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text, :recepient_count, :received_count])
    |> validate_required([:text, :recepient_count, :received_count])
  end
end
