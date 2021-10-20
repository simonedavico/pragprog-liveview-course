defmodule LiveviewStudioWeb.SalesDashboardLive do

  use LiveviewStudioWeb, :live_view
  use Timex

  alias LiveviewStudio.Sales

  def mount(_params, _session, socket) do
    socket = assign_stats(socket)
      |> assign_expiration()
      |> assign(
        refresh_interval: 1,
        last_updated_at: Timex.now()
      )

    if connected?(socket) do
      # socket = schedule_refresh(socket)
      # IO.inspect(socket, label: "mount-connected")
      Process.send_after(self(), :tick, socket.assigns.refresh_interval * 1000)
      {:ok, socket}
    else
      IO.inspect(socket, label: "mount")
      {:ok, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <h1>Sales Dashboard</h1>
    <div id="dashboard">
      <div class="stats">
        <div class="stat">
          <span class="value">
            <%= @new_orders %>
          </span>
          <span class="name">
            New Orders
          </span>
        </div>
        <div class="stat">
          <span class="value">
            $<%= @sales_amount %>
          </span>
          <span class="name">
            Sales Amount
          </span>
        </div>
        <div class="stat">
          <span class="value">
            <%= @satisfaction %>%
          </span>
          <span class="name">
            Satisfaction
          </span>
        </div>
      </div>

      <form phx-change="select-refresh">
        <label for="interval">
          Refresh every:
        </label>
        <select id="interval" name="interval">
          <%= options_for_select(refresh_options(), @refresh_interval) %>
        </select>
      </form>

      <div class="pb-4">
        <%= if @time_remaining > 0 do %>
          <span>
            Expires in
          </span>
          <strong>
            <%= format_time(@time_remaining) %>
          </strong>
        <% else %>
          <span>
            Time expired!
          </span>
        <% end %>
      </div>
      <button phx-click="refresh">
        <img src="images/refresh.svg">
        Refresh
      </button>
      <span>Last update:
        <%= Timex.format!(@last_updated_at, "%H:%M:%S", :strftime) %>
      </span>
    </div>
    """
  end

  def handle_event("refresh", _params, socket) do
    {:noreply, assign_stats(socket)}
  end

  def handle_event("select-refresh", %{ "interval" => interval }, socket) do
    interval = String.to_integer(interval)
    # Process.cancel_timer(socket.assigns.timer_ref, async: false)

    socket = socket
      |> assign(refresh_interval: interval)
      # |> schedule_refresh()

    # Process.send_after(self(), :tick, socket.assigns.refresh_interval * 1000)

    IO.inspect(socket, label: "select-refresh")
    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    # socket = schedule_refresh(socket)
    socket = socket
    |> assign_stats()
    |> assign(
      time_remaining: time_remaining(socket.assigns.expiration_time),
      last_updated_at: Timex.now()
    )

    Process.send_after(self(), :tick, socket.assigns.refresh_interval * 1000)

    IO.inspect(socket, label: "tick")

    {:noreply, socket}
  end

  defp assign_stats(socket) do
    assign(socket,
      new_orders: Sales.new_orders(),
      sales_amount: Sales.sales_amount,
      satisfaction: Sales.satisfaction()
    )
  end

  defp assign_expiration(socket) do
    expiration_time = Timex.shift(Timex.now(), minutes: 1)
    assign(socket,
      expiration_time: expiration_time,
      time_remaining: time_remaining(expiration_time)
    )
  end

  defp time_remaining(expiration_time) do
    DateTime.diff(expiration_time, Timex.now())
  end

  defp format_time(time) do
    time
    |> Timex.Duration.from_seconds()
    |> Timex.format_duration(:humanized)
  end

  defp refresh_options do
    [{"1s", 1}, {"5s", 5}, {"15s", 15}, {"30s", 30}, {"60s", 60}]
  end

  # defp schedule_refresh(socket) do
  #   # timer_ref = Process.send_after(self(), :tick, socket.assigns.refresh_interval * 1000)
  #   # assign(socket, timer_ref: timer_ref)
  #   Process.send_after(self(), :tick, socket.assigns.refresh_interval * 1000)
  #   socket
  # end
end
