defmodule Schulze.Repo.Migrations.Electio do
  use Ecto.Migration

  def change do
    create table(:elections) do
      add(:content, :binary)
      add(:winners, :jsonb)
    end
  end
end
