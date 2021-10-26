defmodule LiveviewStudioWeb.LightLive do
  use LiveviewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10, temperature: 3000)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Front porch light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%; background-color: #{temp_color(@temperature)}"}>
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

      <form phx-change="update">
        <input class="my-8" type="range" min="0" max="100"
          name="brightness" value={@brightness} />

        <div class="">
          <input type="radio" id="3000" name="temp" value="3000" checked={@temperature == 3000} />
          <label for="3000">3000</label>

          <input type="radio" id="4000" name="temp" value="4000" checked={@temperature == 4000} />
          <label for="4000">4000</label>

          <input type="radio" id="5000" name="temp" value="5000" checked={@temperature == 5000} />
          <label for="5000">5000</label>
        </div>
      </form>
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

  def handle_event("update", %{ "brightness" => brightness, "temp" => temperature }, socket) do
    brightness = String.to_integer(brightness)
    temperature = String.to_integer(temperature)
    {:noreply, assign(socket, brightness: brightness, temperature: temperature)}
  end

  defp temp_color(3000), do: "#F1C40D"
  defp temp_color(4000), do: "#FEFF66"
  defp temp_color(5000), do: "#99CCFF"
end
