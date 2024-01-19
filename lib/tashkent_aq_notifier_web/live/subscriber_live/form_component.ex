defmodule TashkentAqNotifierWeb.SubscriberLive.FormComponent do
  use TashkentAqNotifierWeb, :live_component

  alias TashkentAqNotifier.Subscribers

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage subscriber records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="subscriber-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:first_name]} type="text" label="First name" />
        <.input field={@form[:is_bot]} type="checkbox" label="Is bot" />
        <.input field={@form[:language_code]} type="text" label="Language code" />
        <.input field={@form[:username]} type="text" label="Username" />
        <.input field={@form[:chat_id]} type="number" label="Chat" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Subscriber</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{subscriber: subscriber} = assigns, socket) do
    changeset = Subscribers.change_subscriber(subscriber)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"subscriber" => subscriber_params}, socket) do
    changeset =
      socket.assigns.subscriber
      |> Subscribers.change_subscriber(subscriber_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"subscriber" => subscriber_params}, socket) do
    save_subscriber(socket, socket.assigns.action, subscriber_params)
  end

  defp save_subscriber(socket, :edit, subscriber_params) do
    case Subscribers.update_subscriber(socket.assigns.subscriber, subscriber_params) do
      {:ok, subscriber} ->
        notify_parent({:saved, subscriber})

        {:noreply,
         socket
         |> put_flash(:info, "Subscriber updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_subscriber(socket, :new, subscriber_params) do
    case Subscribers.create_subscriber(subscriber_params) do
      {:ok, subscriber} ->
        notify_parent({:saved, subscriber})

        {:noreply,
         socket
         |> put_flash(:info, "Subscriber created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
