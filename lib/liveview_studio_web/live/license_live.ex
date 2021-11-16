defmodule LiveviewStudioWeb.LicenseLive do
  use LiveviewStudioWeb, :live_view

  alias LiveviewStudio.Licenses
  import Number.Currency

  def mount(_params, _session, socket) do
    expiration_time = Timex.shift(Timex.now(), hours: 1)

    [{_label, refresh_interval} | _rest] = refresh_options()

    timer_ref =
      if connected?(socket) do
        Process.send_after(self(), :tick, refresh_interval * 1000)
      end

    socket =
      assign(socket,
        expiration_time: expiration_time,
        remaining_time: remaining_time(expiration_time),
        refresh_interval: refresh_interval,
        timer_ref: timer_ref,
        seats: 3,
        amount: Licenses.calculate(3)
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Team License</h1>
    <div id="license">
      <div class="card">
        <div class="content">
          <div class="seats">
            <img src="images/license.svg">
            <span>
              Your license is currently for
              <strong><%= @seats %></strong> seats.
            </span>
          </div>

          <form phx-change="update">
            <input type="range" min="1" max="10" name="seats" value={@seats} phx-change="250" />
            <select id="refresh-interval" name="refresh-interval">
              <%= options_for_select(refresh_options(), @refresh_interval) %>
            </select>
          </form>

          <div class="amount">
            <%= number_to_currency(@amount) %>
          </div>

          <p class="m-4 font-semibold text-indigo-800">
            <%= if @remaining_time > 0 do %>
              <%= format_time(@remaining_time) %>
            <% else %>
              Expired!
            <% end %>
          </p>

          <div class="expiration-time">
            <%= @expiration_time %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event(
        "update",
        %{"seats" => seats, "refresh-interval" => refresh_interval},
        %{assigns: %{timer_ref: timer_ref}} = socket
      ) do
    refresh_interval = String.to_integer(refresh_interval)
    seats = String.to_integer(seats)

    timer_ref =
      if timer_ref do
        Process.cancel_timer(timer_ref, async: false)
        Process.send_after(self(), :tick, refresh_interval * 1000)
      end

    socket =
      assign(socket,
        timer_ref: timer_ref,
        refresh_interval: refresh_interval,
        seats: seats,
        amount: Licenses.calculate(seats)
      )

    {:noreply, socket}
  end

  def handle_info(
        :tick,
        %{
          assigns: %{
            expiration_time: expiration_time,
            refresh_interval: refresh_interval
          }
        } = socket
      ) do
    remaining_time = remaining_time(expiration_time)

    timer_ref = Process.send_after(self(), :tick, refresh_interval * 1000)

    socket = assign(socket, remaining_time: remaining_time, timer_ref: timer_ref)

    {:noreply, socket}
  end

  defp remaining_time(expiration_time), do: DateTime.diff(expiration_time, Timex.now())

  defp format_time(time) do
    time
    |> Timex.Duration.from_seconds()
    |> Timex.format_duration(:humanized)
  end

  defp refresh_options do
    [{"1s", 1}, {"5s", 5}, {"15s", 15}, {"30s", 30}, {"60s", 60}]
  end
end
