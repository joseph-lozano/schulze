defmodule Bot do
  @candidates ~w(Alice Bob Charlie Doug Ellie)

  @possible_votes (for a <- 1..5,
                       b <- 1..5,
                       c <- 1..5,
                       d <- 1..5,
                       e <- 1..5 do
                     Enum.zip(@candidates, [a, b, c, d, e])
                     |> Enum.into(%{})
                   end)

  use GenServer
  @candidates ~w(Alice Bob Charlie Doug Ellie)

  def create_elections(number) when is_integer(number) do
    1..number
    |> Enum.each(fn i ->
      Schulze.create_election("Random Election #{i}", @candidates)
    end)
  end

  def start_link(number) when is_integer(number) do
    1..number
    |> Enum.map(fn i ->
      {:ok, pid} = start_link()
      :timer.sleep(i * 50)
      pid
    end)
  end

  def start_link(), do: GenServer.start_link(__MODULE__, [])
  def init([]), do: {:ok, [], {:continue, :get_elections}}

  def handle_continue(:get_elections, _state) do
    {elections, _} = Schulze.all_elections(nil, %{page_size: 100})

    Process.send_after(self(), :refresh, rand_time(5, 15))
    Process.send_after(self(), :vote, rand_time(1, 10))
    {:noreply, elections}
  end

  def handle_info(:vote, state) do
    election = Enum.random(state)
    vote = Enum.random(@possible_votes)
    Schulze.cast_vote(election, vote)
    Process.send_after(self(), :vote, rand_time(1, 10))
    {:noreply, state}
  end

  def handle_info(:refresh, _state) do
    {elections, _} = Schulze.all_elections(nil, %{page_size: 100})
    Process.send_after(self(), :refresh, rand_time(5, 15))
    {:noreply, elections}
  end

  defp rand_time(a, b) do
    :crypto.rand_uniform(:timer.seconds(a), :timer.seconds(b))
  end
end
