defmodule Schulze do
  @moduledoc """
  Votex keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def subscribe(topic) do
    SchulzeWeb.Endpoint.subscribe(topic)
  end

  def broadcast(topic, event, payload) do
    SchulzeWeb.Endpoint.broadcast(topic, event, payload)
  end

  def topic(nil), do: "election:new:common"
  def topic(user_id), do: "election:new#{user_id}"

  defdelegate all_elections(id, page), to: __MODULE__.Impl
  defdelegate create_election(name, candidates, user_id, voters), to: __MODULE__.Impl
  def create_election(name, candidates), do: create_election(name, candidates, nil, 0)
  defdelegate get_election(id), to: __MODULE__.Impl
  defdelegate delete_election(id), to: __MODULE__.Impl
  defdelegate cast_vote(election, vote), to: __MODULE__.Impl
  defdelegate get_winner(election), to: __MODULE__.Impl
end
