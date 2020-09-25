defmodule VotexWeb.SchulzeLive.Index do
  alias Votex.Schulze
  use VotexWeb, :live_view

  def mount(_params, _session, socket) do
    ballots = Schulze.all_ballots()
    {:ok, assign(socket, ballots: ballots)}
  end
end
