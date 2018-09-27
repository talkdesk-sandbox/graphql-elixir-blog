defmodule Blog.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset


  schema "comments" do
    field :content, :string
    field :created_at, :date

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :created_at])
    |> validate_required([:content, :created_at])
  end
end
