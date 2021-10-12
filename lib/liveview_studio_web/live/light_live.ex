defmodule LiveviewStudioWeb.LightLive do
  use LiveviewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Front porch light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%"}>
          <%= @brightness %>%
        </span>
      </div>

      <button phx-click="off">
        <img src="images/light-off.svg" alt="">
      </button>

      <button phx-click="down">
        <img src="images/down.svg" alt="">
      </button>

      <button phx-click="up">
        <img src="images/up.svg" alt="">
      </button>

      <button phx-click="on">
        <img src="images/light-on.svg" alt="">
      </button>
    </div>
    """
  end

  def handle_event("on", _, socket) do
    {:noreply, assign(socket, brightness: 100)}
  end

  def handle_event("down", _, socket) do
    {:noreply, update(socket, :brightness, &(&1 - 10))}
  end

  def handle_event("up", _, socket) do
    {:noreply, update(socket, :brightness, &(&1 + 10))}
  end

  def handle_event("off", _, socket) do
    {:noreply, assign(socket, brightness: 0)}
  end
end
