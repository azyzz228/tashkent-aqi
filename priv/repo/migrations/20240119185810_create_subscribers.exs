defmodule TashkentAqNotifier.Repo.Migrations.CreateSubscribers do
  use Ecto.Migration

  def change do
    create table(:subscribers) do
      add :first_name, :string
      add :is_bot, :boolean, default: false, null: false
      add :language_code, :string
      add :username, :string
      add :chat_id, :string

      timestamps()
    end
  end
end
