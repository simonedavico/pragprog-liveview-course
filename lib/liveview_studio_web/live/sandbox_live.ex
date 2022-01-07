defmodule LiveviewStudioWeb.SandboxLive do
  use LiveviewStudioWeb, :live_view

  alias LiveviewStudioWeb.QuoteComponent
  alias LiveviewStudioWeb.QuoteComponentNew
  alias LiveviewStudioWeb.SandboxCalculatorComponent

  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      weight: nil,
      price: nil
    )}
  end

  def handle_info({:totals, weight, price}, socket) do
    socket = assign(socket, weight: weight, price: price)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Build A Sandbox</h1>

    <div id="sandbox">
      <%= live_component SandboxCalculatorComponent,
        id: "sandbox-calculator"
      %>
      <%= if @weight do %>
        <%= live_component QuoteComponent,
          material: "sand",
          weight: @weight,
          price: @price
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
