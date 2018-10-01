defmodule Blog.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Blog.Accounts.Author
  alias Blog.Posts.Post

  schema "comments" do
    belongs_to :author, Author
    belongs_to :post, Post
    field :content, :string
    field :created_at, :date

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :created_at, :author_id, :post_id])
    |> validate_required([:content, :created_at, :author_id, :post_id])
  end
end
