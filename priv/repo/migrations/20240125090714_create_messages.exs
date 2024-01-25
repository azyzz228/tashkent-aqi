defmodule TashkentAqNotifier.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :text, :text
      add :recepient_count, :integer
      add :received_count, :integer

      timestamps()
    end
  end
end
