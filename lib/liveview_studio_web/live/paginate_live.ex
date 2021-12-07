defmodule LiveviewStudioWeb.PaginateLive do
  use LiveviewStudioWeb, :live_view

  alias LiveviewStudio.Donations

  @permitted_sort_bys ~w(item quantity days_until_expires)
  @permitted_sort_orders ~w(asc desc)

  def mount(_params, _session, socket) do
    total_donations = Donations.count_donations()

    socket = assign(socket, total_donations: total_donations)

    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _uri, socket) do
    page = param_to_integer(params["page"], 1)
    per_page = param_to_integer(params["per_page"], 5)
    sort_by =
      params
      |> param_or_first_permitted("sort_by", @permitted_sort_bys)
      |> String.to_atom()

    sort_order =
      params
      |> param_or_first_permitted("sort_order", @permitted_sort_orders)
      |> String.to_atom()

    paginate_options = %{page: page, per_page: per_page}
    sort_options = %{sort_by: sort_by, sort_order: sort_order}
    donations = Donations.list_donations(paginate: paginate_options, sort: sort_options)

    socket =
      assign(socket,
        donations: donations,
        options: Map.merge(paginate_options, sort_options)
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
                <%= sort_link(@socket, "Item", @options, :item) %>
              </th>
              <th>
                <%= sort_link(@socket, "Quantity", @options, :quantity) %>
              </th>
              <th>
                <%= sort_link(@socket, "Days until expires", @options, :days_until_expires) %>
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
              <%= pagination_link(@socket, "Previous", @options.page - 1, @options.per_page, @options.sort_by, @options.sort_order, "previous") %>
            <% end %>
            <%= for i <- (@options.page - 2)..(@options.page + 2), i > 0 do %>
              <%= if i <= ceil(@total_donations / @options.per_page) do %>
                <%= pagination_link(@socket, i, i, @options.per_page, @options.sort_by, @options.sort_order, (if i == @options.page, do: "active")) %>
              <% end %>
            <% end %>
            <%= if (@options.page * @options.per_page) < @total_donations do %>
              <%= pagination_link(@socket, "Next", @options.page + 1, @options.per_page, @options.sort_by, @options.sort_order, "next") %>
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
      to: Routes.live_path(
        socket,
        __MODULE__,
        page: socket.assigns.options.page,
        per_page: per_page,
        sort_by: socket.assigns.options.sort_by,
        sort_order: socket.assigns.options.sort_order
      )
    )

    {:noreply, socket}
  end

  defp pagination_link(socket, text, page, per_page, sort_by, sort_order, class) do
    live_patch(text,
      to: Routes.live_path(
        socket,
        __MODULE__,
        page: page,
        per_page: per_page,
        sort_by: sort_by,
        sort_order: sort_order
      ),
      class: class
    )
  end

  defp sort_link(socket, text, options, sort_by) do
    new_sort_order = toggle_sort_order(options.sort_order)

    text =
      case options do
        %{sort_by: ^sort_by, sort_order: sort_order} ->
          text <> emoji(sort_order)

        _ ->
          text
      end

    live_patch(text,
      to: Routes.live_path(
        socket,
        __MODULE__,
        page: options.page,
        per_page: options.per_page,
        sort_by: sort_by,
        sort_order: new_sort_order
      )
    )
  end

  defp toggle_sort_order(:asc), do: :desc
  defp toggle_sort_order(:desc), do: :asc

  defp emoji(:asc), do: "👇"
  defp emoji(:desc), do: "👆"

  defp expires_class(donation) do
    if Donations.almost_expired?(donation), do: "eat-now", else: "fresh"
  end

  defp param_or_first_permitted(params, key, permitted) do
    value = params[key]
    if value in permitted, do: value, else: hd(permitted)
  end

  defp param_to_integer(nil, default_value), do: default_value
  defp param_to_integer(param, default_value) do
    case Integer.parse(param) do
      {number, _} ->
        number

      :error ->
        default_value
    end
  end

end
