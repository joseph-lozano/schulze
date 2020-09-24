defmodule Votex.ShulzeTest do
  use ExUnit.Case
  alias Votex.Shulze

  describe "new_ballot/1" do
    test "starts a ballot with the candidates and no votes" do
      candidates = ["Alice", "Bob", "Charlie"]
      assert {:ok, %Shulze.Ballot{} = ballot} = Shulze.new_ballot(candidates)
      assert ballot.candidates == candidates
      assert ballot.votes == %{}
    end

    test "fails if 2 candidates share a name" do
      candidates = ["Alice", "Alice", "Bob", "Charlie"]
      assert {:error, "Candidates must be unique"} = Shulze.new_ballot(candidates)
    end
  end
end
