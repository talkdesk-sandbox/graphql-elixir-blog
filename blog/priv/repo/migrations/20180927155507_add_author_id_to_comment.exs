defmodule Blog.Repo.Migrations.AddAuthorIdToComment do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :author_id, :string
    end
  end
end
