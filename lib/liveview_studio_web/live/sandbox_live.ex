defmodule LiveviewStudioWeb.SandboxLive do
  use LiveviewStudioWeb, :live_view

  alias LiveviewStudioWeb.QuoteComponent
  alias LiveviewStudioWeb.QuoteComponentNew
  alias LiveviewStudioWeb.SandboxCalculatorComponent
  alias LiveviewStudioWeb.DeliveryChargeComponent

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      weight: nil,
      price: nil,
      delivery_charge: 0
    )}
  end

  def handle_info({:totals, weight, price}, socket) do
    socket = assign(socket, weight: weight, price: price)
    {:noreply, socket}
  end

  def handle_info({:delivery, charge}, socket) do
    socket = assign(socket, delivery_charge: charge)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Build A Sandbox</h1>

    <div id="sandbox">
      <%= live_component SandboxCalculatorComponent,
        id: "sandbox-calculator"
      %>
      <%= live_component DeliveryChargeComponent,
        id: "delivery-charge"
      %>
      <%= if @weight do %>
        <%= live_component QuoteComponent,
          material: "sand",
          weight: @weight,
          price: @price,
          delivery_charge: @delivery_charge
        %>
      <% end %>
      <QuoteComponentNew.quote
        material="sand"
        weight={@weight}
        price={@price}
        hrs_until_expires="4"
      />
    </div>
    """
  end
end
