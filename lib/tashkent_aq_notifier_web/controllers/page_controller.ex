defmodule TashkentAqNotifierWeb.PageController do
  alias TashkentAqNotifier.Subscribers
  use TashkentAqNotifierWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def handle_update(conn, %{"message" => %{"text" => "/start"}} = params) do
    %{"message" => %{"chat" => %{"id" => id}, "from" => new_subscriber}} = params
    spawn(fn -> handle_new_subscriber(new_subscriber, id) end)

    {:ok, _msg} =
      Telegex.send_message(
        id,
        "
        Xush kelibsiz! Ushbu bot 07:00-dan 23:00-gacha Toshkent havosi sifati va zararligi haqida har 3 soat xabarlaydi. Bot hech qanday davlat idorasi bilan aloqador emas. Ma'lumotlar ochiq manbalardan olinadi. O'lcho'v timizlar AQSH Elchixonasi va TDTU joylashgan.\n
Добро пожаловать! Данный бот будет информировать вас о уровне загрязнения воздуха в Ташкенте каждый 3 часа с 07:00 до 23:00. Бот не аффилирован ни с каким государственным органом. Данные с сенсоров (расположенные в посольстве США, ТГТУ) берутся с открытых источников.\n
Welcome! This bot will send updates on air quality in Tashkent every 3 hours from 07:00 to 23:00. Not affiliated with any government body. Based on open source data coming from US Embassy and TSTU.\n
        "
      )

    case Cachex.get!(:cache, :latest_measurement) do
      nil -> nil
      msg -> Telegex.send_message(id, msg)
    end

    conn
    |> return_conn()
  end

  def handle_update(
        conn,
        %{"my_chat_member" => %{"new_chat_member" => %{"status" => "kicked"}}} = params
      ) do
    %{"my_chat_member" => %{"chat" => %{"id" => id}}} = params

    spawn(fn ->
      id
      |> Subscribers.update_subscriber_status_to_unsubscribed()
    end)

    conn
    |> return_conn()
  end

  def handle_update(conn, _params) do
    conn
    |> return_conn()
  end

  defp return_conn(conn) do
    conn
    |> put_status(200)
    |> put_resp_content_type("application/json")
    |> json(%{})
  end

  defp handle_new_subscriber(new_subscriber, id) do
    new_subscriber
    |> Map.put("chat_id", Integer.to_string(id))
    |> Subscribers.create_subscriber()
    |> case do
      {:error, changeset} ->
        if Keyword.get(changeset.errors, :chat_id, false) do
          Subscribers.update_subscriber_status_to_subcribed(id)
        end

      {:ok, _} ->
        nil
    end
  end
end
