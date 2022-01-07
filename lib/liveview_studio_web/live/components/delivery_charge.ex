defmodule LiveviewStudioWeb.DeliveryChargeComponent do
  use LiveviewStudioWeb, :live_component

  alias LiveviewStudio.SandboxCalculator

  import Number.Currency

  def mount(socket) do
    socket = assign(socket,
      zip: nil,
      charge: 0
    )
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <form phx-change="calculate" phx-target={@myself}>
      <div class="field">
        <label for="zip">Zip Code:</label>
        <input type="text" name="zip" value={@zip} />
        <span class="unit"><%= number_to_currency(@charge) %></span>
      </div>
    </form>
    """
  end

  def handle_event("calculate", params, socket) do
    %{"zip" => zip} = params

    charge = SandboxCalculator.calculate_delivery_charge(zip)

    send(self(), {:delivery, charge})

    {:noreply, assign(socket,
      zip: zip,
      charge: charge
    )}
  end

end
