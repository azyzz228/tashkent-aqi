defmodule TashkentAqNotifierWeb.PageController do
  alias TashkentAqNotifier.Subscribers
  use TashkentAqNotifierWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def handle_update(conn, %{"message" => %{"text" => "/start"}} = params) do
    IO.puts("/start")
    dbg(params)

    %{"message" => %{"chat" => %{"id" => id}, "from" => new_subscriber}} = params

    spawn(fn -> handle_new_subscriber(new_subscriber, id) end)

    {:ok, _msg} =
      Telegex.send_message(
        id,
        "
        Xush kelibsiz! Ushbu bot 07:00-dan 23:00-gacha Toshkent havosi sifati va zararligi haqida soatma-soat xabarlaydi.\n
        Добро пожаловать! Данный бот будет информировать вас о уровне загрязнения воздуха в Ташкенте каждый час с 07:00 до 23:00.\n
        Welcome! This bot will send hourly updates on air quality in Tashkent from 07:00 to 23:00.
        "
      )

    conn
    |> put_status(200)
    |> put_resp_content_type("application/json")
    |> json(%{})
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
    |> put_status(200)
    |> put_resp_content_type("application/json")
    |> json(%{})
  end

  def handle_update(conn, params) do
    IO.puts("regular message")

    dbg(params)

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
