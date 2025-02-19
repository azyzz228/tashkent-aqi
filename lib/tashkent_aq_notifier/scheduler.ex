defmodule TashkentAqNotifier.Scheduler do
  alias TashkentAqNotifier.Notification
  alias TashkentAqNotifier.Subscribers
  alias TashkentAqNotifier.Subscribers.Subscriber
  use GenServer

  @three_hours_in_ms 60 * 60 * 3 * 1000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    initiate_scheduler()
    {:ok, state}
  end

  def handle_info(:broadcast, state) do
    now = uz_time_now()

    if now.hour > 7 do
      broadcast()
    end

    schedule()
    {:noreply, state}
  end

  def schedule() do
    Process.send_after(self(), :broadcast, @three_hours_in_ms)
  end

  def initiate_scheduler() do
    now = uz_time_now()
    # minutes = now.minute - 7
    # later = now |> DateTime.add(1, :hour) |> DateTime.add(-minutes, :minute)
    later = now |> DateTime.add(2, :minute)

    ms_before_next_hour_01_minute = DateTime.diff(later, now, :millisecond)
    Process.send_after(self(), :broadcast, ms_before_next_hour_01_minute)
  end

  def broadcast() do
    notification_message_query =
      Task.async(TashkentAqNotifier.Notifier, :get_notification_message, [])

    active_subscribers_query =
      Task.async(TashkentAqNotifier.Subscribers, :list_active_subscribers, [])

    notification_message = Task.await(notification_message_query)
    active_subscribers = Task.await(active_subscribers_query)

    successfully_sent_count =
      active_subscribers
      |> Enum.map(fn %Subscriber{} = subscriber ->
        case Telegex.send_message(
               subscriber.chat_id,
               notification_message
             ) do
          {:ok, _} ->
            true

          {:error, %Telegex.Error{description: "Bad Request: chat not found", error_code: 400}} ->
            spawn(fn ->
              Subscribers.update_subscriber_status_to_unsubscribed(subscriber.chat_id)
            end)

            nil

          {:error,
           %Telegex.Error{description: "Forbidden: bot was blocked by the user", error_code: 403}} ->
            spawn(fn ->
              Subscribers.update_subscriber_status_to_unsubscribed(subscriber.chat_id)
            end)

            nil

          _ ->
            nil
        end
      end)
      |> Enum.filter(fn item -> item == true end)
      |> Enum.count()

    spawn(fn ->
      Notification.create_message(%{
        text: notification_message,
        recepient_count: active_subscribers |> Enum.count(),
        received_count: successfully_sent_count
      })
    end)
  end

  def broadcast(message) when is_binary(message) do
    active_subscribers = Subscribers.list_active_subscribers()

    successfully_sent_count =
      active_subscribers
      |> Enum.map(fn %Subscriber{} = subscriber ->
        case Telegex.send_message(
               subscriber.chat_id,
               message
             ) do
          {:ok, _} ->
            true

          {:error, %Telegex.Error{description: "Bad Request: chat not found", error_code: 400}} ->
            spawn(fn ->
              Subscribers.update_subscriber_status_to_unsubscribed(subscriber.chat_id)
            end)

            nil

          {:error, _} ->
            nil
        end
      end)
      |> Enum.filter(fn item -> item == true end)
      |> Enum.count()

    spawn(fn ->
      Notification.create_message(%{
        text: message,
        recepient_count: active_subscribers |> Enum.count(),
        received_count: successfully_sent_count
      })
    end)
  end

  defp uz_time_now() do
    DateTime.utc_now() |> DateTime.add(5, :hour)
  end
end
