defmodule Blog.Repo.Migrations.ChangeFieldsComments do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      remove :author_id
      remove :post_id
      add :author_id, references(:authors)
      add :post_id, references(:posts)
    end
  end
end
