defmodule LiveviewStudioWeb.DatePickerLive do
  use LiveviewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, date: nil)}
  end

  def handle_event("date-selected", %{ "date" => date }, socket) do
    {:noreply, assign(socket, date: date)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <form>
        <input id="date-picker-input" type="text"
               class="form-input" value={@date}
               placeholder="Pick a date"
               phx-hook="Flatpickr">
      </form>

      <%= if @date do %>
        <p class="mt-6 text-xl">
          See you on <%= @date %>!
        </p>
      <% end %>
    </div>
    """
  end
end
