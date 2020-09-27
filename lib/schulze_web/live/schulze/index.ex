defmodule SchulzeWeb.SchulzeLive.Index do
  @moduledoc false
  use SchulzeWeb, :live_view

  def mount(params, session, socket) do
    user_token = Map.get(session, "user_token")
    user = user_token && Schulze.Accounts.get_user_by_session_token(user_token)
    user_id = user && user.id

    Schulze.subscribe(Schulze.topic(user_id))

    {elections, meta} = Schulze.all_elections(user_id, params)
    elections = Enum.map(elections, &{&1.id, &1})

    {:ok, assign(socket, elections: elections, params: params, meta: meta, user_id: user_id)}
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
        elections = socket.assigns.elections
        index = Enum.find_index(elections, fn {election_id, _} -> election_id == id end)

        elections = List.delete_at(elections, index)

        assign(socket, elections: elections) |> noreply()

      {:error, reason} ->
        put_flash(socket, :error, reason) |> noreply()
    end
  end

  def handle_event("get_page", %{"pager" => params}, socket) do
    params =
      Map.merge(socket.assigns.params, params)
      |> Map.to_list()

    socket
    |> push_patch(to: Routes.live_path(socket, __MODULE__, params))
    |> noreply()
  end

  def handle_event("get_page", params, socket) do
    params = Map.take(params, ["page", "page_size", "total_pages"])

    Map.merge(socket.assigns.params, params)
    |> Map.to_list()

    socket
    |> push_patch(to: Routes.live_path(socket, __MODULE__, params))
    |> noreply()
  end

  def handle_params(params, _, socket) when map_size(params) == 0 do
    {:noreply, socket}
  end

  def handle_params(%{} = params, _, socket) do
    user_id = socket.assigns.user_id
    {elections, meta} = Schulze.all_elections(user_id, params)
    elections = Enum.map(elections, &{&1.id, &1})
    IO.inspect({params, meta})
    {:noreply, assign(socket, elections: elections, params: params, meta: meta)}
  end

  def handle_info(%{event: "new_election", payload: %{id: id}}, socket) do
    case Schulze.get_election(id) do
      %Schulze.Election{} = election ->
        elections = [{id, election} | socket.assigns.elections] |> Enum.sort_by(&elem(&1, 0))

        socket
        |> assign(elections: elections)
        |> noreply()

      _ ->
        noreply(socket)
    end
  end

  defp noreply(socket), do: {:noreply, socket}
end
