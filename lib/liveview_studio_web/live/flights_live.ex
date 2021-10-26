defmodule LiveviewStudioWeb.FlightsLive do
  use LiveviewStudioWeb, :live_view

  alias LiveviewStudio.Flights

  use Timex

  def mount(_params, _session, socket) do
    socket = assign(socket,
      flights: [],
      loading: false
    )
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Find a Flight</h1>
    <div id="search">

      <%= if @loading do %>
        <div class="loader">Loading...</div>
      <% end %>

      <form phx-submit="search-flight">
        <input type="text" name="number" value="" autofocus
               placeholder="Search by number" autocomplete="off" readonly={@loading} />
        <button type="submit">
          <img src="images/search.svg" />
        </button>
      </form>

      <div class="flights">
        <ul>
          <%= for flight <- @flights do %>
            <li>
              <div class="first-line">
                <div class="number">
                  Flight #<%= flight.number %>
                </div>
                <div class="origin-destination">
                  <img src="images/location.svg">
                  <%= flight.origin %> to
                  <%= flight.destination %>
                </div>
              </div>
              <div class="second-line">
                <div class="departs">
                  Departs: <%= Timex.format!(flight.departure_time, "{YYYY}-{0M}-{D} {h24}:{m}") %>
                </div>
                <div class="arrives">
                  Arrives: <%= Timex.format!(flight.arrival_time, "{YYYY}-{0M}-{D} {h24}:{m}") %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_info({:do_search_flight, number}, socket) do
    socket = case Flights.search_by_number(number) do
      [] ->
        socket
        |> put_flash(:info, "No flights found for number #{number}")
        |> assign(loading: false, flights: [])
      flights ->
        socket
        |> clear_flash()
        |> assign(loading: false, flights: flights)
    end

    {:noreply, socket}
  end

  def handle_event("search-flight", %{ "number" => number }, socket) do
    send(self(), {:do_search_flight, number})
    socket = assign(socket,
      loading: true
    )
    {:noreply, socket}
  end
end
