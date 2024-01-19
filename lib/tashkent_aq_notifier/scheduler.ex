defmodule TashkentAqNotifier.Scheduler do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    initiate_scheduler()
    {:ok, state}
  end

  def handle_info(:broadcast, state) do
    now = get_time_in_tashkent_now()

    if now.hour > 7 do
      broadcast()
    end

    schedule()
    {:noreply, state}
  end

  def schedule() do
    Process.send_after(self(), :broadcast, 5_000)
  end

  def initiate_scheduler() do
    now = get_time_in_tashkent_now()
    minutes = now.minute - 1
    later = now |> DateTime.add(1, :hour) |> DateTime.add(-minutes, :minute)

    ms_before_next_hour_01_minute = DateTime.diff(later, now, :millisecond)
    Process.send_after(self(), :broadcast, ms_before_next_hour_01_minute)
  end

  defp broadcast() do
    now = get_time_in_tashkent_now()
    ids = [242_087_850, 6_169_337_963]

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
  end

  defp get_time_in_tashkent_now() do
    DateTime.utc_now() |> DateTime.add(5, :hour)
  end
end
