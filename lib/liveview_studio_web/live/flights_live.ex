defmodule LiveviewStudioWeb.FlightsLive do
  use LiveviewStudioWeb, :live_view

  alias LiveviewStudio.Flights
  alias LiveviewStudio.Airports

  use Timex

  def mount(_params, _session, socket) do
    socket = assign(socket,
      airport: "",
      flights: [],
      airports: [],
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

      <form phx-submit="search-airport" phx-change="suggest-airport">
        <input type="text" name="airport" value="" autofocus list="airports" phx-debounce="1000"
               placeholder="Search by airport" autocomplete="off" readonly={@loading} />
        <button type="submit">
          <img src="images/search.svg" />
        </button>
      </form>

      <datalist id="airports">
        <%= for airport <- @airports do %>
          <option value={airport}>
            <%= airport %>
          </option>
        <% end %>
      </datalist>

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

  def handle_info({:do_search_airport, airport}, socket) do
    socket = case Flights.search_by_airport(airport) do
      [] ->
        socket
        |> put_flash(:info, "No flights found for airport #{airport}")
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

  def handle_event("search-airport", %{ "airport" => airport }, socket) do
    send(self(), {:do_search_airport, airport})

    socket = assign(socket,
      airport: airport,
      flights: [],
      loading: true
    )
    {:noreply, socket}
  end

  def handle_event("suggest-airport", %{ "airport" => prefix }, socket) do
    socket = assign(socket,
      airports: Airports.suggest(prefix)
    )
    {:noreply, socket}
  end
end
