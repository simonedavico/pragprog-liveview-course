defmodule LiveviewStudioWeb.ServersLive do
  use LiveviewStudioWeb, :live_view

  alias LiveviewStudio.Servers
  alias LiveviewStudio.Servers.Server

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()

    socket =
      assign(socket,
        servers: servers,
        selected_server: hd(servers)
      )

     {:ok, socket}
  end

  # invoked after mount
  # state that changes based on navigation should be set here
  def handle_params(%{"name" => name}, _url, socket) do
    server = Servers.get_server_by_name(name)

    socket =
      assign(socket,
        selected_server: server,
        page_title: "#{server.name}"
      )

    {:noreply, socket}
  end

  # catchall case
  def handle_params(_params, _url, socket) do
    socket = cond do
      new_server?(socket) -> assign(socket,
        new_server: Servers.change_server(%Server{})
      )
      true -> socket
    end

    {:noreply, socket}
  end

  def handle_event("save", %{ "server" => params }, socket) do
    case Servers.create_server(params) do
      {:ok, server} ->
        changeset = Servers.change_server(%Server{})

        socket = update(
          socket,
          :servers,
          fn servers -> [server | servers] end
        )
        |> assign(changeset: changeset)
        |> put_flash(:info, "Server created!")
        |> push_patch(to: Routes.live_path(socket, __MODULE__, name: server.name))

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  def handle_event("toggle_status", %{ "id" => id }, socket) do
    id = String.to_integer(id)
    server = Servers.get_server!(id)

    {:ok, server} = Servers.toggle_server_status(server)

    # refetch for simplicity , but we could also update
    # the matching server in the current list
    servers = Servers.list_servers()
      |> IO.inspect()

    {:noreply, assign(socket,
      servers: servers,
      selected_server: server
    )}
  end

  def handle_event("validate", %{ "server" => params }, socket) do
    changeset = %Server{}
      |> Servers.change_server(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, new_server: changeset)}
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
      <nav>
        <%= live_patch "Add new server",
          to: Routes.servers_path(@socket, :new),
          class: "button"
        %>
          <%= for server <- @servers do %>
            <div>
              <%= live_patch link_body(server),
                to: Routes.live_path(@socket, __MODULE__, name: server.name),
                class: if server == @selected_server, do: "active"
              %>
            </div>
          <% end %>
        </nav>
      </div>
      <div class="main">
        <div class="wrapper">
          <%= if @live_action == :new do %>
            <%= new_server(%{ new_server: @new_server, socket: @socket }) %>
          <% else %>
            <%= server_detail(%{ selected_server: @selected_server }) %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp new_server(assigns) do
    ~H"""
      <.form let={f} for={@new_server} phx-submit="save" phx-change="validate">
        <div class="field">
          <label>
            Name
            <%= text_input f,
              :name,
              placeholder: "Name",
              autocomplete: "off",
            phx_debounce: "blur" %>
          </label>
          <%= error_tag f, :name %>
        </div>

        <div class="field">
          <label>
            Framework
            <%= text_input f,
              :framework,
              placeholder: "Framework",
              autocomplete: "off",
              phx_debounce: "blur" %>
          </label>
          <%= error_tag f, :framework %>
        </div>

        <div class="field">
          <label>
            Size
            <%= text_input f,
              :size,
              placeholder: "Size",
              autocomplete: "off",
              phx_debounce: "blur" %>
          </label>
          <%= error_tag f, :size %>
        </div>

        <div class="field">
          <label>
            Git repo
            <%= text_input f,
              :git_repo,
              placeholder: "Git Repo",
              autocomplete: "off",
              phx_debounce: "blur" %>
          </label>
          <%= error_tag f, :git_repo %>
        </div>

        <%= submit "Create", phx_disable_with: "Creating..." %>
        <%= live_patch "Cancel",
          to: Routes.live_path(@socket, __MODULE__),
          class: "cancel"
        %>
      </.form>
    """
  end

  defp server_detail(assigns) do
    ~H"""
    <div class="card">
    <div class="header">
      <h2><%= @selected_server.name %></h2>
      <button
        class={@selected_server.status}
        phx-disable-with="Saving..."
        phx-click="toggle_status"
        phx-value-id={@selected_server.id}
      >
        <%= @selected_server.status %>
      </button>
    </div>
    <div class="body">
      <div class="row">
        <div class="deploys">
          <img src="/images/deploy.svg">
          <span>
            <%= @selected_server.deploy_count %> deploys
          </span>
        </div>
        <span>
          <%= @selected_server.size %> MB
        </span>
        <span>
          <%= @selected_server.framework %>
        </span>
      </div>
      <h3>Git Repo</h3>
      <div class="repo">
        <%= @selected_server.git_repo %>
      </div>
      <h3>Last Commit</h3>
      <div class="commit">
        <%= @selected_server.last_commit_id %>
      </div>
      <blockquote>
        <%= @selected_server.last_commit_message %>
      </blockquote>
    </div>
    </div>
    """
  end

  defp link_body(server) do
    assigns = %{name: server.name, status: server.status}

    ~H"""
    <span class={"status #{@status}"}></span>
    <img src="/images/server.svg" alt="server icon">
    <%= @name %>
    """
  end

  defp new_server?(socket) do
    socket.assigns.live_action == :new
  end

end
