defmodule LiveViewStudioWeb.PizzaOrdersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.PizzaOrders
  import Number.Currency

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        pizza_orders: PizzaOrders.list_pizza_orders()
      )

    {:ok, socket}
  end

  def handle_params(%{"sort_by" => sort_by, "sort_order" => sort_order}, _uri, socket) do
    sort_by = valid_sort_by(sort_by)
    sort_order = valid_sort_order(sort_order)

    options = %{
      sort_by: sort_by,
      sort_order: sort_order
    }

    socket =
      assign(socket,
        options: options,
        pizza_orders: PizzaOrders.list_pizza_orders(options)
      )

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, options: %{sort_by: :id, sort_order: :asc})}
  end

  attr :sort_by, :atom, required: true
  attr :options, :map, required: true
  slot :inner_block, required: true

  def sort_link(assigns) do
    ~H"""
    <.link patch={~p"/pizza-orders?#{%{sort_by: @sort_by, sort_order: next_sort_order(@options.sort_order)}}"}>
      <%= render_slot(@inner_block) %> <%= sort_indicator(@sort_by, @options) %>
    </.link>
    """
  end

  defp next_sort_order(:asc), do: :desc
  defp next_sort_order(_), do: :asc

  defp valid_sort_by(sort_by)
        when sort_by in ~w(id style size topping_1 topping_2 price) do
    String.to_atom(sort_by)
  end

  defp valid_sort_by(_), do: :id

  defp valid_sort_order("desc"), do: :desc
  defp valid_sort_order(_), do: :asc

  defp sort_indicator(column, %{sort_by: sort_by, sort_order: sort_order})
        when column == sort_by do
    case sort_order do
      :asc -> "👆"
      :desc -> "👇"
    end
  end

  defp sort_indicator(_, _), do: ""
end
