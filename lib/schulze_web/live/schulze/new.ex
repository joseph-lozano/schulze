defmodule SchulzeWeb.SchulzeLive.New do
  alias Schulze.Election
  @moduledoc false

  use SchulzeWeb, :live_view

  def mount(_params, session, socket) do
    user_token = Map.get(session, "user_token")
    user = user_token && Schulze.Accounts.get_user_by_session_token(user_token)
    user_id = user && user.id
    changeset = Election.new(%Election{}, %{user_id: user_id})
    candidates = add_extra([])

    {:ok,
     assign(socket,
       changeset: changeset,
       private: false,
       user_id: user_id,
       candidates: candidates,
       voters: 0,
       end_time: false,
       passwords: [],
       created: false
     )}
  end

  def handle_event("submit", %{"election" => params}, socket) do
    %{"name" => name} = params
    user_id = socket.assigns.user_id
    candidates = get_candidates(params)

    voters =
      case params["voters"] do
        "" -> 0
        x -> String.to_integer(x)
      end

    case Schulze.create_election(name, candidates, user_id, voters) do
      {:error, changeset} ->
        socket
        |> assign(changest: changeset)
        |> put_flash(:error, "See Errors below")
        |> noreply()

      {:ok, %Schulze.Election{id: id, passwords: passwords}} ->
        socket
        |> put_flash(:info, "Election Created")
        |> assign(passwords: passwords, id: id, created: true)
        |> noreply()
    end
  end

  def handle_event("validate", %{"election" => params}, socket) do
    %{"name" => name} = params
    private? = params["private?"] == "true"
    end_time? = params["end_time?"] == "true"
    user_id = socket.assigns.user_id

    candidates = get_candidates(params)

    voters =
      case params["voters"] do
        "" -> 0
        x -> String.to_integer(x)
      end

    cs =
      Election.new(%Election{}, %{
        name: name,
        candidates: candidates,
        user_id: user_id,
        voters: voters
      })

    {:noreply,
     assign(socket,
       candidates: add_extra(candidates),
       name: name,
       end_time: end_time?,
       private: private?,
       changeset: cs,
       voters: socket.assigns.voters
     )}
  end

  defp add_extra(candidates) do
    case candidates do
      [] -> ["", ""]
      l -> l ++ [""]
    end
  end

  defp get_candidates(params) do
    Enum.filter(params, fn {key, _} -> String.starts_with?(key, "candidate_") end)
    |> Enum.map(fn {key, val} ->
      {String.slice(key, 10..-1) |> String.to_integer(), val}
    end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn {_, name} -> name end)
    |> Enum.reject(fn name -> name == "" end)
  end

  defp noreply(socket), do: {:noreply, socket}
end
