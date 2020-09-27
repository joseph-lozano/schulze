defmodule Schulze.StoredElection do
  @moduledoc "Wrapper for storing Elections"
  use Ecto.Schema
  alias Schulze.Repo
  require Ecto.Query

  schema "elections" do
    field(:content, Schulze.Term)
    field(:winners, {:array, {:array, :string}})
    field(:is_common, :boolean)
    belongs_to(:user, Schulze.Accounts.User)
  end

  def all(user_id, page \\ 1)

  def all(nil, page) do
    __MODULE__
    |> Ecto.Query.order_by(asc: :id)
    |> Ecto.Query.where(is_common: true)
    |> paginate(page)
  end

  def all(user_id, params) do
    __MODULE__
    |> Ecto.Query.order_by(asc: :id)
    |> Ecto.Query.where(user_id: ^user_id)
    |> paginate(params)
  end

  def paginate(query, params) do
    %{entries: entries, page_number: page_number, total_pages: total_pages, page_size: page_size} =
      Repo.paginate(query, params)

    {Enum.map(entries, & &1.content),
     [page_number: page_number, total_pages: total_pages, page_size: page_size]}
  end

  def update(term) do
    changeset(%__MODULE__{id: term.id}, %{content: term, winners: term.winners})
    |> Repo.update()
    |> case do
      {:ok, %__MODULE__{content: content}} -> {:ok, content}
      e -> e
    end
  end

  def create(term, user_id) do
    common? = is_nil(user_id)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :first_insert,
      changeset(%__MODULE__{}, %{content: term, user_id: user_id, is_common: common?})
    )
    |> Ecto.Multi.run(:get_id, fn _repo,
                                  %{first_insert: %{id: id, content: content} = stored_election} ->
      Repo.update(changeset(stored_election, %{content: put_in(content.id, id)}))
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
    Ecto.Changeset.cast(term, attrs, [:content, :winners, :user_id, :is_common])
  end
end
