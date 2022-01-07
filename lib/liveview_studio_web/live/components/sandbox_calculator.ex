defmodule LiveviewStudioWeb.SandboxCalculatorComponent do

  use LiveviewStudioWeb, :live_component

  alias LiveviewStudio.SandboxCalculator

  def mount(socket) do
    socket = assign(socket,
      length: nil,
      width: nil,
      depth: nil,
      weight: 0
    )
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <form phx-submit="get-quote" phx-change="calculate" phx-target={@myself}>
      <div class="field">
        <label for="length">Length:</label>
        <input type="number" name="length" value={@length} />
        <span class="unit">feet</span>
      </div>
      <div class="field">
        <label for="width">Width:</label>
        <input type="number" name="width" value={@width} />
        <span class="unit">feet</span>
        </div>
      <div class="field">
        <label for="depth">Depth:</label>
        <input type="number" name="depth" value={@depth} />
        <span class="unit">inches</span>
      </div>
      <div class="weight">
        You need <%= @weight %> pounds
      </div>
      <button type="submit">
        Get Quote
      </button>
    </form>
    """
  end

  def handle_event("calculate", params, socket) do
    %{"length" => l, "width" => w, "depth" => d} = params

    weight = SandboxCalculator.calculate_weight(l, w, d)

    {:noreply, assign(socket,
      length: l,
      width: w,
      depth: d,
      weight: weight
    )}
  end

  def handle_event("get-quote", _params, socket) do
    weight = socket.assigns.weight
    price = SandboxCalculator.calculate_price(weight)

    send(self(), {:totals, weight, price})

    {:noreply, socket}
  end

end
