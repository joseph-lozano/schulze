defmodule Votex do
  @moduledoc """
  Votex keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def subscribe(topic) do
    VotexWeb.Endpoint.subscribe(topic)
  end
end
