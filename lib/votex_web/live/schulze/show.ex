defmodule VotexWeb.SchulzeLive.Show do
  use VotexWeb, :live_view
  alias Votex.Schulze

  def mount(%{"id" => id}, _session, socket) do
    {:ok, ballot} = Schulze.get_ballot(id)

    votes = length(ballot.votes)
    candidates = ballot.candidates |> Enum.shuffle()

    {:ok, assign(socket, id: id, votes: votes, candidates: candidates)}
  end

  def handle_event("submit", %{"ballot" => params}, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end
end
