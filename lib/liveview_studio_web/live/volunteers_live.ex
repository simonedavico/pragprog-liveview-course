defmodule LiveviewStudioWeb.VolunteersLive do
  use LiveviewStudioWeb, :live_view

  alias LiveviewStudio.Volunteers
  alias LiveviewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
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
      {:ok, volunteer} ->
        changeset = Volunteers.change_volunteer(%Volunteer{})

        socket = update(
          socket,
          :volunteers,
          fn volunteers -> [volunteer | volunteers] end
        ) |> assign(changeset: changeset)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

end
