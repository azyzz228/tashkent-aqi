defmodule TashkentAqNotifierWeb.SubscriberLiveTest do
  use TashkentAqNotifierWeb.ConnCase

  import Phoenix.LiveViewTest
  import TashkentAqNotifier.SubscribersFixtures

  @create_attrs %{id: 42, username: "some username", first_name: "some first_name", is_bot: true, language_code: "some language_code", chat_id: 42}
  @update_attrs %{id: 43, username: "some updated username", first_name: "some updated first_name", is_bot: false, language_code: "some updated language_code", chat_id: 43}
  @invalid_attrs %{id: nil, username: nil, first_name: nil, is_bot: false, language_code: nil, chat_id: nil}

  defp create_subscriber(_) do
    subscriber = subscriber_fixture()
    %{subscriber: subscriber}
  end

  describe "Index" do
    setup [:create_subscriber]

    test "lists all subscribers", %{conn: conn, subscriber: subscriber} do
      {:ok, _index_live, html} = live(conn, ~p"/subscribers")

      assert html =~ "Listing Subscribers"
      assert html =~ subscriber.username
    end

    test "saves new subscriber", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/subscribers")

      assert index_live |> element("a", "New Subscriber") |> render_click() =~
               "New Subscriber"

      assert_patch(index_live, ~p"/subscribers/new")

      assert index_live
             |> form("#subscriber-form", subscriber: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#subscriber-form", subscriber: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/subscribers")

      html = render(index_live)
      assert html =~ "Subscriber created successfully"
      assert html =~ "some username"
    end

    test "updates subscriber in listing", %{conn: conn, subscriber: subscriber} do
      {:ok, index_live, _html} = live(conn, ~p"/subscribers")

      assert index_live |> element("#subscribers-#{subscriber.id} a", "Edit") |> render_click() =~
               "Edit Subscriber"

      assert_patch(index_live, ~p"/subscribers/#{subscriber}/edit")

      assert index_live
             |> form("#subscriber-form", subscriber: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#subscriber-form", subscriber: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/subscribers")

      html = render(index_live)
      assert html =~ "Subscriber updated successfully"
      assert html =~ "some updated username"
    end

    test "deletes subscriber in listing", %{conn: conn, subscriber: subscriber} do
      {:ok, index_live, _html} = live(conn, ~p"/subscribers")

      assert index_live |> element("#subscribers-#{subscriber.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#subscribers-#{subscriber.id}")
    end
  end

  describe "Show" do
    setup [:create_subscriber]

    test "displays subscriber", %{conn: conn, subscriber: subscriber} do
      {:ok, _show_live, html} = live(conn, ~p"/subscribers/#{subscriber}")

      assert html =~ "Show Subscriber"
      assert html =~ subscriber.username
    end

    test "updates subscriber within modal", %{conn: conn, subscriber: subscriber} do
      {:ok, show_live, _html} = live(conn, ~p"/subscribers/#{subscriber}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Subscriber"

      assert_patch(show_live, ~p"/subscribers/#{subscriber}/show/edit")

      assert show_live
             |> form("#subscriber-form", subscriber: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#subscriber-form", subscriber: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/subscribers/#{subscriber}")

      html = render(show_live)
      assert html =~ "Subscriber updated successfully"
      assert html =~ "some updated username"
    end
  end
end
