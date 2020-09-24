defmodule Votex.Shulze.Ballot do
  use TypedStruct

  @typep candidate_list :: [String.t()]

  typedstruct do
    field(:candidates, candidate_list(), default: [])
    field(:votes, %{candidate_list() => pos_integer()}, default: %{})
  end
end
