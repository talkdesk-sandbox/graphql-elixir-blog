defmodule Blog.Repo.Migrations.AddAuthorIdToPost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :author_id, :string
    end
  end
end
