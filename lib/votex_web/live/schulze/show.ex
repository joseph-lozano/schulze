defmodule VotexWeb.SchulzeLive.Show do
  use VotexWeb, :live_view
  alias Votex.Schulze

  def mount(%{"id" => id}, _session, socket) do
    Votex.subscribe("schulze:#{id}")

    case Schulze.get_election(id) do
      {:error, reason} ->
        socket
        |> redirect(to: Routes.live_path(socket, VotexWeb.SchulzeLive.Index))
        |> put_flash(:error, reason)
        |> ok()

      election ->
        {:ok, assign(socket, id: id, election: election)}
    end
  end

  def handle_event("submit", %{"ballot" => vote}, socket) do
    election = socket.assigns.election

    with {:ok, election} <- Schulze.cast_vote(election, vote),
         {:ok, _election} <- Schulze.update_election(election.name, election) do
      socket
      |> push_redirect(to: Routes.live_path(socket, VotexWeb.SchulzeLive.Index))
      |> put_flash(:info, "Vote Cast")
      |> no_reply()
    end
  end

  def handle_info(%{event: "election_updated"}, socket) do
    {:noreply, socket}
  end

  defp no_reply(socket), do: {:noreply, socket}
  defp ok(socket), do: {:ok, socket}
end
