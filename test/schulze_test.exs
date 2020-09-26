defmodule SchulzeTest do
  use ExUnit.Case
  alias Schulze.Impl

  describe "create_election/1" do
    test "takes params" do
    end
  end

  describe "new_election/1" do
    test "starts a election with the candidates and no votes" do
      candidates = ["Alice", "Bob", "Charlie"]
      assert {:ok, %Schulze.Election{} = election} = Schulze.new_election("test", candidates)
      assert election.candidates == candidates
      assert election.votes == []
    end

    test "fails if 2 candidates share a name" do
      candidates = ["Alice", "Alice", "Bob", "Charlie"]
      assert {:error, "Candidates must be unique"} = Schulze.new_election("test", candidates)
    end
  end

  describe "cast_vote/2" do
    setup do
      {:ok, election} = Schulze.new_election("test", ["Alice", "Bob", "Charlie"])
      %{election: election}
    end

    test "takes votes correctly", %{election: election} do
      vote1 = %{"Alice" => 3, "Bob" => 2, "Charlie" => 1}
      {:ok, election1} = Schulze.cast_vote(election, vote1)
      assert election1.votes == [vote1]

      vote2 = %{"Alice" => 3, "Bob" => 1, "Charlie" => 1}
      {:ok, election2} = Schulze.cast_vote(election1, vote2)
      assert election2.votes == [vote2, vote1]
    end

    test "reject votes with a negative number", %{election: election} do
      vote = %{"Alice" => -1}
      assert {:error, "Preferences cannot be negative"} = Schulze.cast_vote(election, vote)
    end

    test "reject votes with a wrong candidate", %{election: election} do
      vote = %{"Doug" => 1}
      assert {:error, "Candidate not on election"} = Schulze.cast_vote(election, vote)
    end
  end
end
