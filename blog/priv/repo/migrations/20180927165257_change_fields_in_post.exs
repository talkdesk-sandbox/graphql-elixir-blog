defmodule Blog.Repo.Migrations.ChangeFieldsInPost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      remove :author_id
      add :author_id, :id
    end
  end
end
