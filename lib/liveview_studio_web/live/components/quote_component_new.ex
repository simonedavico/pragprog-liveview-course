defmodule LiveviewStudioWeb.QuoteComponentNew do
  use Phoenix.Component

  import Number.Currency

  def quote(assigns) do
    assigns = assign_new(assigns, :hrs_until_expires, fn -> 24 end)

    ~H"""
    <div
      class={"text-center p-6 border-4 border-dashed border-indigo-600 #{unless @weight, do: 'hidden'}"}
    >
      <h2 class="text-2xl mb-2">
        Our best deal:
      </h2>
      <h3 class="text-xl font-semibold text-indigo-600">
        <%= @weight %> pounds of <%= @material %>
        for <%= number_to_currency(@price) %>
      </h3>
      <div class="text-gray-600">
        expires in <%= @hrs_until_expires %> hours
      </div>
    </div>
    """
  end

end
