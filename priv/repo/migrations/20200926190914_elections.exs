defmodule Schulze.Repo.Migrations.Election do
  use Ecto.Migration

  def change do
    create table(:elections) do
      add(:name, :string, null: false)
      add(:winners, :jsonb)
      add(:votes, {:array, :map}, null: false)
      add(:candidates, {:array, :string})
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:is_common, :boolean)
    end

    create(index(:elections, [:is_common]))
    create(index(:elections, [:user_id]))
  end
end
