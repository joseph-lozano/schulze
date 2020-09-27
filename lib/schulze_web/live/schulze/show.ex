defmodule SchulzeWeb.SchulzeLive.Show do
  @moduledoc false
  use SchulzeWeb, :live_view

  def mount(%{"id" => id}, _session, socket) do
    Schulze.subscribe("election_updates")
    id = String.to_integer(id)

    case Schulze.get_election(id) do
      {:error, reason} ->
        socket
        |> redirect(to: Routes.live_path(socket, SchulzeWeb.SchulzeLive.Index))
        |> put_flash(:error, reason)
        |> ok()

      election ->
        candidates = Enum.shuffle(election.candidates)
        {:ok, assign(socket, id: id, election: election, candidates: candidates)}
    end
  end

  def handle_event("submit", %{"ballot" => vote}, socket) do
    election = socket.assigns.election

    case Schulze.cast_vote(election, vote) do
      {:ok, _} ->
        socket
        |> push_redirect(to: Routes.live_path(socket, SchulzeWeb.SchulzeLive.Index))
        |> put_flash(:info, "Vote Cast")
        |> no_reply()

      {:error, _reason} ->
        socket
        |> put_flash(:error, "Error Casting Vote")
        |> no_reply()
    end
  end

  def handle_info(%{event: _, payload: %{id: id}}, socket) do
    with true <- id == socket.assigns.id,
         election <- Schulze.get_election(id) do
      {:noreply, assign(socket, election: election)}
    else
      _ ->
        {:noreply, socket}
    end
  end

  defp no_reply(socket), do: {:noreply, socket}
  defp ok(socket), do: {:ok, socket}
end
