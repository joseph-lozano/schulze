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

  # defdelegate all_elections(), to: __MODULE__.Impl
  defdelegate all_elections(id), to: __MODULE__.Impl
  defdelegate create_election(name, candidates), to: __MODULE__.Impl
  defdelegate get_election(id), to: __MODULE__.Impl
  defdelegate delete_election(id), to: __MODULE__.Impl
  defdelegate cast_vote(election, vote), to: __MODULE__.Impl
  @spec get_winner(Schulze.Election.t()) :: any
  defdelegate get_winner(election), to: __MODULE__.Impl
end
