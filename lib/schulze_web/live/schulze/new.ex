defmodule SchulzeWeb.SchulzeLive.New do
  @moduledoc false

  use SchulzeWeb, :live_view

  def mount(_params, session, socket) do
    user_token = Map.get(session, "user_token")
    user = user_token && Schulze.Accounts.get_user_by_session_token(user_token)
    user_id = user && user.id
    {:ok, assign(socket, candidates: [{1, ""}], name: "", user_id: user_id)}
  end

  def handle_event("submit", %{"schulze_election" => params}, socket) do
    %{"name" => name} = params
    user_id = socket.assigns.user_id
    candidates = get_candidates(params) |> Enum.map(&elem(&1, 1))

    case Schulze.create_election(name, candidates, user_id) do
      {:error, reason} ->
        socket |> put_flash(:error, reason) |> noreply()

      {:ok, _} ->
        socket
        |> put_flash(:info, "Created Election")
        |> push_redirect(to: Routes.live_path(socket, SchulzeWeb.SchulzeLive.Index))
        |> noreply()
    end
  end

  def handle_event("validate", %{"schulze_election" => params}, socket) do
    %{"name" => name} = params

    candidates =
      get_candidates(params)
      |> maybe_add_extra()

    {:noreply, assign(socket, candidates: candidates, name: name)}
  end

  defp maybe_add_extra(candidates) do
    remove_empty = Enum.reject(candidates, fn {_, name} -> name == "" end)

    last_i =
      case List.last(remove_empty) do
        nil -> 0
        {last_i, _} -> last_i
      end

    remove_empty ++ [{last_i + 1, ""}]
  end

  defp get_candidates(params) do
    Enum.filter(params, fn {key, _} -> String.starts_with?(key, "candidate_") end)
    |> Enum.map(fn {key, val} -> {String.slice(key, 10..-1) |> String.to_integer(), val} end)
    |> Enum.reject(fn {_, name} -> name == "" end)
  end

  defp noreply(socket), do: {:noreply, socket}
end
