defmodule Reuse.Repo.Migrations.RemoveUniqueIndex do
  use Ecto.Migration

  def change do
    drop constraint(:todos, :todos_index)
    create index(:todos, [:index], unique: false)
  end
end
