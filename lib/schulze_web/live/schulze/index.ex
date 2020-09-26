defmodule SchulzeWeb.SchulzeLive.Index do
  @moduledoc false
  use SchulzeWeb, :live_view

  def mount(_params, session, socket) do
    user_token = Map.get(session, "user_token")
    user = user_token && Schulze.Accounts.get_user_by_session_token(user_token)

    elections =
      Schulze.all_elections(user[:id])
      |> Enum.map(&{&1.id, &1})

    {:ok, assign(socket, elections: elections)}
  end

  def handle_event("get_winner", %{"id" => id}, socket) do
    id = String.to_integer(id)
    elections = socket.assigns.elections

    elections
    |> Enum.find(fn {election_id, _} -> election_id == id end)
    |> elem(1)
    |> Schulze.get_winner()
    |> case do
      {:ok, won_election} ->
        elections =
          elections
          |> Enum.into(%{})
          |> Map.put(won_election.id, won_election)
          |> Enum.into([])
          |> Enum.sort_by(&elem(&1, 0))

        {:noreply, assign(socket, elections: elections)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, inspect(reason))}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    case Schulze.delete_election(id) do
      :ok ->
        elections =
          Schulze.all_elections()
          |> Enum.map(&{&1.id, &1})

        assign(socket, elections: elections) |> noreply()

      {:error, reason} ->
        put_flash(socket, :error, reason) |> noreply()
    end
  end

  defp noreply(socket), do: {:noreply, socket}
end
