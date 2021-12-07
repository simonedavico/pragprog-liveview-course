defmodule LiveviewStudioWeb.PaginateLive do
  use LiveviewStudioWeb, :live_view

  alias LiveviewStudio.Donations

  def mount(_params, _session, socket) do
    total_donations = Donations.count_donations()

    socket = assign(socket, total_donations: total_donations)

    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _uri, socket) do
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "5")
    paginate_options = %{page: page, per_page: per_page}
    donations = Donations.list_donations(paginate: paginate_options)

    socket =
      assign(socket,
        donations: donations,
        options: paginate_options
      )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Food Bank Donations</h1>
    <div id="donations">
      <form phx-change="select_per_page">
        Show
        <select name="per_page">
          <%= options_for_select([5, 10, 15, 20], @options.per_page) %>
        </select>
        <label for="per_page">per page</label>
      </form>
      <div class="wrapper">
        <table>
          <thead>
            <tr>
              <th class="item">
                Item
              </th>
              <th>
                Quantity
              </th>
              <th>
                Days Until Expires
              </th>
            </tr>
          </thead>
          <tbody>
            <%= for donation <- @donations do %>
              <tr>
                <td class="item">
                  <span class="id"><%= donation.id %></span>
                  <%= donation.emoji %> <%= donation.item %>
                </td>
                <td>
                  <%= donation.quantity %> lbs
                </td>
                <td>
                  <span class={expires_class(donation)}>
                    <%= donation.days_until_expires %>
                  </span>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
        <div class="footer">
          <div class="pagination">
            <%= if @options.page > 1 do %>
              <%= pagination_link(@socket, "Previous", @options.page - 1, @options.per_page, "previous") %>
            <% end %>
            <%= for i <- (@options.page - 2)..(@options.page + 2), i > 0 do %>
              <%= if i <= ceil(@total_donations / @options.per_page) do %>
                <%= pagination_link(@socket, i, i, @options.per_page, (if i == @options.page, do: "active")) %>
              <% end %>
            <% end %>
            <%= if (@options.page * @options.per_page) < @total_donations do %>
              <%= pagination_link(@socket, "Next", @options.page + 1, @options.per_page, "next") %>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("select_per_page", %{"per_page" => per_page}, socket) do
    # update url, handle_params gets invoked
    socket = push_patch(socket,
      to: Routes.live_path(socket, __MODULE__, page: socket.assigns.options.page, per_page: per_page)
    )

    {:noreply, socket}
  end

  defp pagination_link(socket, text, page, per_page, class) do
    live_patch(text,
      to: Routes.live_path(
        socket,
        __MODULE__,
        page: page,
        per_page: per_page
      ),
      class: class
    )
  end

  defp expires_class(donation) do
    if Donations.almost_expired?(donation), do: "eat-now", else: "fresh"
  end
end
