defmodule TashkentAqNotifier.Scheduler do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    schedule()
    {:ok, state}
  end

  def handle_info(:broadcast, state) do
    ids = [242_087_850, 6_169_337_963]

    now = DateTime.utc_now() |> DateTime.add(5, :hour)

    Enum.each(ids, fn id ->
      case Telegex.send_message(
             id,
             "Hello chat id #{id}, this is a broadcast, sent at #{now.hour}:#{now.minute}:#{now.second}"
           ) do
        {:error, error} ->
          # TODO: delete from DB if chat_id is not found (or just mark it as inactive)
          dbg(error)

        {:ok, _} ->
          nil
      end
    end)

    schedule()

    {:noreply, state}
  end

  def schedule() do
    Process.send_after(self(), :broadcast, 5_000)
  end
end
