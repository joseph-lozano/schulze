defmodule Schulze.Repo.Migrations.StoredElection do
  use Ecto.Migration

  def change do
    create table(:elections) do
      add(:content, :binary, null: false)
      add(:winners, :jsonb)
      add(:user_id, references(:users, on_delete: :nilify_all))
    end
  end
end
