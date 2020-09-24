defmodule Votex.SchulzeTest do
  use ExUnit.Case
  alias Votex.Schulze

  describe "new_ballot/1" do
    test "starts a ballot with the candidates and no votes" do
      candidates = ["Alice", "Bob", "Charlie"]
      assert {:ok, %Schulze.Ballot{} = ballot} = Schulze.new_ballot(candidates)
      assert ballot.candidates == candidates
      assert ballot.votes == %{}
    end

    test "fails if 2 candidates share a name" do
      candidates = ["Alice", "Alice", "Bob", "Charlie"]
      assert {:error, "Candidates must be unique"} = Schulze.new_ballot(candidates)
    end
  end

  describe "cast_vote/2" do
    setup do
      {:ok, ballot} = Schulze.new_ballot(["Alice", "Bob", "Charlie"])
      %{ballot: ballot}
    end

    test "Takes votes correctly", %{ballot: ballot} do
      vote1 = %{"Alice" => 3, "Bob" => 2, "Charlie" => 1}
      {:ok, ballot1} = Schulze.cast_vote(ballot, vote1)
      assert ballot1.votes == %{[["Alice"], ["Bob"], ["Charlie"]] => 1}

      vote2 = %{"Alice" => 1, "Bob" => 2, "Charlie" => 3}
      {:ok, ballot2} = Schulze.cast_vote(ballot, vote2)
      assert ballot2.votes == %{[["Charlie"], ["Bob"], ["Alice"]] => 1}

      vote2 = %{"Alice" => 3, "Bob" => 1, "Charlie" => 1}
      {:ok, ballot2} = Schulze.cast_vote(ballot, vote2)
      assert ballot2.votes == %{[["Alice"], ["Bob", "Charlie"]] => 1}

      # A smae vote should increment by one
      {:ok, ballot3} = Schulze.cast_vote(ballot2, vote2)
      assert ballot3.votes == %{[["Alice"], ["Bob", "Charlie"]] => 2}
    end
  end
end
