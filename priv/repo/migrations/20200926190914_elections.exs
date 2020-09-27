defmodule Schulze.Repo.Migrations.StoredElection do
  use Ecto.Migration

  def change do
    create table(:elections) do
      add(:content, :binary, null: false)
      add(:winners, :jsonb)
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:is_common, :boolean)
    end

    create(index(:elections, [:is_common]))
    create(index(:elections, [:user_id]))
  end
end
