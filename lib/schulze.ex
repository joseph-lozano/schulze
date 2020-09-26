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

  defdelegate all_elections, to: __MODULE__.Impl
  defdelegate create_election(arg1, arg2), to: __MODULE__.Impl
  defdelegate get_election(arg), to: __MODULE__.Impl
  defdelegate delete_election(arg), to: __MODULE__.Impl
  defdelegate cast_vote(arg1, arg2), to: __MODULE__.Impl
  defdelegate get_winner(arg), to: __MODULE__.Impl
end
