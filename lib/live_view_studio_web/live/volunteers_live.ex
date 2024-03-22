defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    socket =
      assign(socket,
        volunteers: volunteers,
        form: to_form(Volunteers.change_volunteer(%Volunteer{}))
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.form for={@form} phx-submit="signup">
        <.input field={@form[:name]} placeholder="Name" autocomplete="off"/>
        <.input field={@form[:phone]} placeholder="Phone" autocomplete="off" type="tel"/>
        <.button phx-disable-with="Submitting...">
          Submit
        </.button>
      </.form>
      <div
        :for={volunteer <- @volunteers}
        class={"volunteer #{if volunteer.checked_out, do: "out"}"}
      >
        <div class="name">
          <%= volunteer.name %>
        </div>
        <div class="phone">
          <%= volunteer.phone %>
        </div>
        <div class="status">
          <button>
            <%= if volunteer.checked_out, do: "Check In", else: "Check Out" %>
          </button>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("signup", params, socket) do
    v = params["volunteer"]
    case Volunteers.create_volunteer(%Volunteer{}, v) do
      {:ok, volunteer} ->
        socket = assign(socket, form: to_form(Volunteers.change_volunteer(%Volunteer{})))
        # socket = update(socket, )
        {:noreply, assign(socket, :volunteer)}
    end
    IO.inspect(v)
    {:noreply, socket}
  end
end
