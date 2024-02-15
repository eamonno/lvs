defmodule LiveViewStudioWeb.VehiclesLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Vehicles
  import LiveViewStudioWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        vehicles: [],
        loading: false,
        query: nil,
        suggestions: []
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>🚙 Find a Vehicle 🚘</h1>
    <div id="vehicles">
      <form phx-submit="search" phx-change="suggest">
        <input
          type="text"
          name="query"
          value={ @query }
          placeholder="Make or model"
          autofocus
          autocomplete="off"
          readonly={@loading}
          list="suggestions"
          phx-debounce="1000"
        />

        <button>
          <img src="/images/search.svg" />
        </button>
      </form>

      <datalist id="suggestions">
        <option :for={ suggestion <- @suggestions } value={suggestion}>
          <%= suggestion %>
        </option>
      </datalist>

      <.loading_indicator visible={ @loading } />

      <div class="vehicles">
        <ul>
          <li :for={vehicle <- @vehicles}>
            <span class="make-model">
              <%= vehicle.make_model %>
            </span>
            <span class="color">
              <%= vehicle.color %>
            </span>
            <span class={"status #{vehicle.status}"}>
              <%= vehicle.status %>
            </span>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("search", %{ "query" => query}, socket) do
    send(self(), {:search, query})
    socket =
      assign(socket,
        loading: true,
        query: query,
        vehicles: []
      )

    {:noreply, socket}
  end

  def handle_event("suggest", %{ "query" => hint }, socket) do
    {:noreply, assign(socket, suggestions: Vehicles.suggest(hint))}
  end

  def handle_info({:search, query}, socket) do
    socket =
      assign(socket,
        vehicles: Vehicles.search(query),
        loading: false
      )

    {:noreply, socket}
  end
end
