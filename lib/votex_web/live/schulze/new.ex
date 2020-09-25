defmodule VotexWeb.SchulzeLive.New do
  use VotexWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, candidates: [{1, ""}], name: "")}
  end

  def handle_event("submit", %{"schulze_ballot" => params}, socket) do
    %{"name" => name} = params
    candidates = get_candidates(params) |> Enum.map(&elem(&1, 1))

    cond do
      name == "" ->
        {:noreply, put_flash(socket, :error, "Name Can't be blank")}

      length(candidates) < 2 ->
        {:noreply, put_flash(socket, :error, "Need at least 2 candidates")}

      Enum.uniq(candidates) != candidates ->
        {:noreply, put_flash(socket, :error, "Candidate Names must be unique")}

      Schulze.create_ballot(params) ->
        {:noreply,
         socket
         |> put_flash(:error, "TODO: Create Ballot")
         |> push_redirect(to: Routes.live_path(socket, VotexWeb.SchulzeLive.Index))}
    end
  end

  def handle_event("validate", %{"schulze_ballot" => params}, socket) do
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
end
