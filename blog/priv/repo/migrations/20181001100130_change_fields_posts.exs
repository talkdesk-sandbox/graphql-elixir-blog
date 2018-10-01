defmodule Blog.Repo.Migrations.ChangeFieldsPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      remove :author_id
      add :author_id, references(:authors)
    end
  end
end
