defmodule TashkentAqNotifier.Repo.Migrations.AddLastNameToSubscribers do
  use Ecto.Migration

  def change do
    alter table(:subscribers) do
      add :last_name, :string
    end
  end
end
