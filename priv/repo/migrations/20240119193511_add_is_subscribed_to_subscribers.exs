defmodule TashkentAqNotifier.Repo.Migrations.AddIsSubscribedToSubscribers do
  use Ecto.Migration

  def change do
    alter table(:subscribers) do
      add :is_subscribed, :boolean
    end
  end
end
