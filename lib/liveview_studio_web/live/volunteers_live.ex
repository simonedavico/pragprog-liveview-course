defmodule LiveviewStudioWeb.VolunteersLive do
  use LiveviewStudioWeb, :live_view

  alias LiveviewStudio.Volunteers
  alias LiveviewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    if connected?(socket), do: Volunteers.subscribe()

    volunteers = Volunteers.list_volunteers()

    changeset = Volunteers.change_volunteer(%Volunteer{})

    socket =
      assign(socket,
        volunteers: volunteers,
        changeset: changeset
      )

    {:ok, socket, temporary_assigns: [volunteers: []]}
  end

  def handle_event("save", %{ "volunteer" => params }, socket) do
    case Volunteers.create_volunteer(params) do
      {:ok, _volunteer} ->
        changeset = Volunteers.change_volunteer(%Volunteer{})
        {:noreply, assign(socket, changeset: changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{ "volunteer" => params }, socket) do
    changeset = Volunteers.change_volunteer(
      %Volunteer{},
      params
    )
    |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("toggle_status", %{ "id" => id }, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, _volunteer} = Volunteers.update_volunteer(volunteer, %{
      checked_out: !volunteer.checked_out
    })

    {:noreply, socket}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    socket = update(
      socket,
      :volunteers,
      fn volunteers -> [volunteer | volunteers] end
    )
    {:noreply, socket}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    socket = update(
      socket,
      :volunteers,
      fn volunteers -> [volunteer | volunteers] end
    )
    {:noreply, socket}
  end

end
