defmodule Blog.Repo.Migrations.ChangeFieldsInComments do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      remove :author_id
      remove :post_id
      add :author_id, :id
      add :post_id, :id
    end
  end
end
