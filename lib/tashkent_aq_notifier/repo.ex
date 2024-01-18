defmodule TashkentAqNotifier.Repo do
  use Ecto.Repo,
    otp_app: :tashkent_aq_notifier,
    adapter: Ecto.Adapters.Postgres
end
