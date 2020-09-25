defmodule VotexWeb.SchulzeLive.Index do
  alias Votex.Schulze
  use VotexWeb, :live_view

  def mount(_params, _session, socket) do
    elections = Schulze.all_elections()
    {:ok, assign(socket, elections: elections)}
  end
end
