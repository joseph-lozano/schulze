defmodule Schulze.Storage do
  @moduledoc "Wrapper for storing Elections"
  use Ecto.Schema
  alias Schulze.Repo
  require Ecto.Query

  schema "elections" do
    field(:content, Schulze.Term)
    field(:winners, {:array, {:array, :string}})
  end

  def all() do
    __MODULE__
    |> Ecto.Query.order_by(asc: :id)
    |> Repo.all()
    |> Enum.map(& &1.content)
  end

  def update(term) do
    changeset(%__MODULE__{id: term.id}, %{content: term, winners: term.winners})
    |> Repo.update()
    |> case do
      {:ok, %__MODULE__{content: content}} -> {:ok, content}
      e -> e
    end
  end

  def create(term) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :first_insert,
      changeset(%__MODULE__{}, %{content: term})
    )
    |> Ecto.Multi.run(:get_id, fn _repo, %{first_insert: %{id: id, content: content} = storage} ->
      Repo.update(changeset(storage, %{content: put_in(content.id, id)}))
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{get_id: %__MODULE__{content: content}}} -> {:ok, content}
      e -> e
    end
  end

  def get(id) do
    case Repo.get(__MODULE__, id) do
      %__MODULE__{content: content} -> content
      _ -> {:error, "Election Not Found"}
    end
  end

  def delete(id) do
    case Repo.delete(%__MODULE__{id: id}) do
      {:ok, _} -> :ok
      e -> e
    end
  end

  def changeset(term, attrs) do
    Ecto.Changeset.cast(term, attrs, [:content, :winners])
  end
end
